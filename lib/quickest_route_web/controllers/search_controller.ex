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
         {:ok, refined_search} <- Search.refine(search_info),
         {:ok, completed_search} <- Search.search(refined_search) do
      sorted_result =
        Enum.sort_by(
          completed_search.search_summary,
          fn {_origin, _alternative, {duration, _distance}, _final_destination} -> duration end
        )

      render(conn, "show.html", response: sorted_result)
    end
  end
end
