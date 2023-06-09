defmodule QuickestRoute.Search.Searcher do
  @moduledoc """
  Searches for trip durations to alternative locations
  """
  alias QuickestRoute.Search.{ApiCaller, Google, Parameters, Place, SearchInfo}

  def refine(
        %Parameters{
          departure_time: departure_time
        } = parameters,
        api_key
      ) do
    refined =
      parameters
      |> prepare(api_key)
      ## BUG - these async tasks get called twice per list member.....
      ## at least when using mimic expect.....
      |> Task.async_stream(&get_refinement/1)
      |> Stream.map(&to_place_struct/1)

    if Enum.all?(refined, fn {_atom, %Place{status: status}} ->
         status in [:ok, :unused]
       end) do
      refined
      |> Enum.reduce(%SearchInfo{}, &to_search_info/2)
      |> Map.put(:departure_time, departure_time)
      |> then(&{:ok, &1})
    else
      {:error, "UNREFINED ERROR DISPLAY NOT IMPLEMENTED"}
      # return error changeset explaining which went unrefined, which will
      # get picked up in fallback controller and displayed back to user
      ## NOTE - what about the case where some were refined, but others weren't?
      ## we would not want to refine successful ones again
      ## suggests collecting more in a single schema
      ## only showing some of the info in UI, keeping
      ## rest in background
    end
  end

  defp prepare(parameters, api_key),
    do:
      parameters
      |> Map.take([:from, :to, :finally])
      |> Map.to_list()
      |> Enum.map(&maybe_distribute_place_context/1)
      |> List.flatten()
      |> Enum.map(fn {place_context, user_input} ->
        {place_context, {user_input, Google.get_place_url(user_input, api_key)}}
      end)

  defp get_refinement({:finally, {nil, nil}} = unused),
    do: unused

  defp get_refinement({place_context, {user_input, url}}),
    do: {place_context, {user_input, ApiCaller.call(url)}}

  defp to_search_info({:finally, %Place{status: :unused}}, search_info) do
    Map.put(search_info, :final_destination, nil)
  end

  defp to_search_info({:finally, finally}, search_info) do
    Map.put(search_info, :final_destination, finally)
  end

  defp to_search_info({:from, from}, search_info) do
    Map.put(search_info, :origin, from)
  end

  defp to_search_info({:to, to}, search_info) do
    alts = search_info.alternatives || []
    Map.put(search_info, :alternatives, [to | alts])
  end

  defp maybe_distribute_place_context({atom, [_ | _] = val}),
    do: Enum.map(val, fn v -> {atom, v} end)

  defp maybe_distribute_place_context(x), do: x

  ## TODO - need another catch for status != OK, as opposed to unused
  ## AND situations where there is more than one candidate
  defp to_place_struct({
         :ok,
         {place_context,
          {user_input,
           %{
             "candidates" => [_ | _] = refined,
             "status" => "OK"
           }}}
       }),
       do: {place_context, %Place{status: :ok, original: user_input, refined: refined}}

  defp to_place_struct({:ok, {place_context, _}}), do: {place_context, %Place{status: :unused}}

  def search(
        %SearchInfo{
          origin: origin,
          alternatives: alternatives
        } = search_info,
        api_key
      ) do
    search_summary =
      alternatives
      |> Stream.map(&Google.get_direction_url(search_info, &1, api_key))
      |> Task.async_stream(&get_directions(&1))
      |> Stream.map(&Google.parse_route_info(&1))
      |> Enum.map(
        &{
          origin,
          &1.alternative,
          &1.route_info,
          search_info[:final_destination]
        }
      )

    Map.put(search_info, :search_summary, search_summary)
  end

  defp get_directions(%{direction_url: url} = intermediate),
    do: Map.put(intermediate, :directions, ApiCaller.call(url))
end
