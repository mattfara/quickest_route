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

  def convert(validated_params), do: {:ok, SearchInfo.init(validated_params)}

  # @spec refine(SearchInfo.t()) :: SearchInfo.t()
  def refine(%SearchInfo{
        origin: from,
        alternatives: [_ | _] = to,
        departure_time: departure_time,
        final_destination: final_destination
      }) do
    api_key = Google.get_api_key()

    {:ok,
     %SearchInfo{
       origin: Google.refine_place(from, api_key),
       departure_time: departure_time,
       alternatives: Enum.map(to, fn x -> Google.refine_place(x, api_key) end),
       final_destination: Google.refine_place(final_destination, api_key)
     }}
  end
end
