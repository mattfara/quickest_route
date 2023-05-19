defmodule QuickestRoute.Search do
  @moduledoc """
  Defines search context
  """
  alias QuickestRoute.Search.{Google, Parameters, Place, Searcher, SearchInfo}

  def search(search_info) do
    search_info
    |> Searcher.search(Google.get_api_key())
    |> then(&{:ok, &1})
  end

  @doc """
  Supplies an empty form for view
  """
  def form, do: Parameters.form()

  def validate(params), do: Parameters.validate(params)

  def convert(%Parameters{} = validated_params), do: {:ok, SearchInfo.init(validated_params)}

  def refine(%Parameters{
        departure_time: departure_time,
      } = parameters) do
    ## TODO - probably move all this into Searcher module, aside from passing the api key
    api_key = Google.get_api_key()

    refined =
     parameters
     |> Map.take([:from, :to, :finally])
     |> Map.to_list()
     |> Enum.map(&convert_to/1)
     |> List.flatten()
     |> Task.async_stream(&Google.refine_place(&1, api_key))

     ## TODO - how could this be made part of the pipe?
     ## considering a generic `or` FN, which might take
     ## a predicate and two FNs as args
     ## like def pipe_or(data, predicate, true_fn, false_fn)
     if Enum.all?(refined, fn {:ok, {_atom, %Place{status: status}}} -> status in [:ok, :unused] end) do
       refined
       |> Enum.reduce(%SearchInfo{}, &to_search_info/2)
       |> Map.put(:departure_time, departure_time)
       |> then(&{:ok, &1})
     else
       {:error, "UNREFINED ERROR DISPLAY NOT IMPLEMENTED"}
       # return error changeset explaining which went unrefined, which will
       # get picked up in fallback controller and displayed back to user
     end
  end

  defp to_search_info({:ok, {:finally, %Place{status: :unused}}}, search_info) do
    Map.put(search_info, :final_destination, nil)
  end

  defp to_search_info({:ok, {:finally, finally}}, search_info) do
    Map.put(search_info, :final_destination, finally)
  end

  defp to_search_info({:ok, {:from, from}}, search_info) do
    Map.put(search_info, :origin, from)
  end

  defp to_search_info({:ok, {:to, to}}, search_info) do
    alts = search_info.alternatives || []
    Map.put(search_info, :alternatives, [to | alts])
  end

  defp convert_to({atom, [_|_] = val}), do:
    Enum.map(val, fn v -> {atom, v} end)

  defp convert_to(x), do: x
end
