defmodule QuickestRoute.Search do
  alias QuickestRoute.Search.{Google, Parameters, Searcher, SearchInfo}

  def search(search_info) do
    search_info
    |> Searcher.search(Google.get_api_key())
    |> then(&{:ok, &1})
  end

  def form, do: Parameters.form()
  def form(form), do: Parameters.form(form)
  def attributes(form), do: Parameters.attributes(form)

  def validate(form) do
    form
    |> Parameters.changeset()
    |> case do
      %{valid?: true, changes: changes, data: %{departure_time: departure_time}} ->
        {:ok, Map.put(changes, :departure_time, departure_time)}

      changeset ->
        {:error, changeset}
    end
  end

  def convert(validated_params) do
    SearchInfo.init(validated_params)
  end

  def refine(%SearchInfo{origin: from, alternatives: to, departure_time: departure_time}) do
    api_key = Google.get_api_key()

    {:ok,
     %SearchInfo{
       origin: Google.refine_place(from, api_key),
       alternatives:
         Enum.reduce(to, [], fn x, acc -> [Google.refine_place(x, api_key) | acc] end),
       departure_time: departure_time
     }}
  end
end
