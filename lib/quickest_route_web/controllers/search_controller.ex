defmodule QuickestRouteWeb.SearchController do
  use QuickestRouteWeb, :controller

  alias QuickestRoute.Search

  def new(conn, _params) do
    changeset = Search.form()
    render(conn, "new.html", changeset: changeset)
  end

  def run(conn, %{"parameters" => params}) do
    with {:ok, validated_params} <- Search.validate(params),
         {:ok, search_info} <- Search.convert(validated_params),
         ## TODO - need to work out how to deal with unrefined results and multiple results
         ## probably use the `else` to drive some view behavior
         ## ask user to try another input or select from the choices, respectively
         {:ok, refined_params} <- Search.refine(search_info),
         {:ok, completed_search} <- Search.search(refined_params) do

    sorted = Enum.sort_by(
      completed_search.durations,
      fn {_origin, _alternative, duration} -> duration end
    )

    render(conn, "show.html", response: sorted)
    end
  end

end
