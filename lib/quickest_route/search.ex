defmodule QuickestRoute.Search do
  @moduledoc """
  Defines search context
  """
  alias QuickestRoute.Search.{Google, Parameters, Searcher, SearchInfo}

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

  # @spec refine(SearchInfo.t()) :: SearchInfo.t()
  def refine(%Parameters{
        departure_time: departure_time,
      } = parameters) do
    api_key = Google.get_api_key()
    ## should do all the refinement in parallel too

    ## should refine TO a place, which has
    ## the user input, the place_id, and refined_name

    ## 1. parallel refinement
    ## 2. if results are good, return OK below
    ## 3. if results are bad, return :error with
    ## a bad changeset to display back to user

    refined =
     parameters
     |> Map.take([:from, :to, :finally])
     |> Map.to_list()
     |> Enum.map(&convert_to/1)
     |> List.flatten()
     |> Task.async_stream(&Google.refine_place(&1, api_key))

     if Enum.all?(refined, fn {:ok, {_atom, %Place{status: status}}} -> status == :ok end) do
       # convert to SearchInfo
       refined
       |> Enum.reduce(%SearchInfo{}, reduce_to_search_info/2)
       |> Map.put(:departure_time, departure_time)
     else
       
       # return error changeset, which will
       # get picked up in fallback controller
     end



     ## now want to confirm
     # 1) all the tasks returned :ok
     # 2) all Place statuses are :ok
     # 3) if so, proceed to convert to a SearchInfo
     # 4) otherwise return bad changeset for Parameters


  #  {:ok,
  #   %SearchInfo{
  #     origin: Google.refine_place(from, api_key),
  #     departure_time: departure_time,
  #     alternatives: Enum.map(to, fn x -> Google.refine_place(x, api_key) end),
  #     final_destination: Google.refine_place(final_destination, api_key)
  #   }}
  end

  defp reduce_to_search_info({:ok, {:finally, finally}}) do
    Map.put(search_info, :final_destination, finally)
  end

  defp reduce_to_search_info({:ok, {:from, from}}, search_info) do
    Map.put(search_info, :origin, finally)
  end

  defp reduce_to_search_info({:ok, {:to, to}}, search_info) do
    alts = search_info.alternatives || []
    Map.put(search_info, :alternatives, [to | alts])
  end

  defp convert_to({atom, [_|_] = val}), do:
    Enum.map(val, fn v -> {atom, v} end)

  defp convert_to(x), do: x
end
