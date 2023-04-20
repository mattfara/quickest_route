defmodule QuickestRoute.Search do
  alias QuickestRoute.Search.{Google, Parameters, Searcher}

  def search(params \\ %{}) do
    params
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

  def refine(%{from: from, to: to, departure_time: departure_time}) do
    api_key = Google.get_api_key()

    {:ok,
     %{
       from: Google.refine_place(from, api_key),
       to: Enum.reduce(to, [], fn x, acc -> [Google.refine_place(x, api_key) | acc] end),
       departure_time: departure_time
     }}
  end
end
