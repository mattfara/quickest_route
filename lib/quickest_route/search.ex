defmodule QuickestRoute.Search do
  alias QuickestRoute.Search.{Parameters, Searcher}

  ## could consider returning a Search w/ a result key, with
  @spec search(map) :: any()
  def search(params \\ %{}) do
    %Parameters{}
    |> Parameters.changeset(params)
    |> Searcher.search()
    |> then(&{:ok, &1})
  end

  def form, do: Parameters.form()
  def form(form), do: Parameters.form(form)
  def attributes(form), do: Parameters.attributes(form)
end
