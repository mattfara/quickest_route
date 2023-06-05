defmodule QuickestRouteWeb.SearchController do
  use QuickestRouteWeb, :controller

  alias QuickestRoute.Search
  alias QuickestRouteWeb.Fallback.FallbackController

  action_fallback(FallbackController)

  def new(conn, _params) do
    changeset = Search.form()
    render(conn, "new.html", changeset: changeset)
  end

  def run(conn, %{"parameters" => params}) do
    with {:ok, validated_params} <- Search.validate(params),
         {:ok, search_info} <- Search.refine(validated_params),
         {:ok, completed_search} <- Search.search(search_info) do
      sorted_result =
        Enum.sort_by(
          completed_search.search_summary,
          fn {_origin, _alternative, {duration, _distance}, _final_destination} -> duration end
        )

      render(conn, "show.html", response: sorted_result)
    end
  end
end
