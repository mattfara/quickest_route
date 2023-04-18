defmodule QuickestRoute.Search do
  alias QuickestRoute.Search.{Google, Parameters, Searcher}

  ## could consider returning a Search w/ a result key, with

  def search(params \\ %{}) do
    params
    |> Searcher.search(Google.get_api_key())
    |> then(&{:ok, &1})
  end

  def form, do: Parameters.form()
  def form(form), do: Parameters.form(form)
  def attributes(form), do: Parameters.attributes(form)

  def refine(attributes \\ %{}) do
    %{changes: %{from: from, to: to}} = Parameters.changeset(%Parameters{}, attributes)
    api_key = Google.get_api_key()

    {:ok,
     %{
       from: Google.refine_place(from, api_key),
       to: Enum.reduce(to, [], fn x, acc -> [Google.refine_place(x, api_key) | acc] end)
     }}
  end
end
