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
        ## maybe we only convert after we get the refined result...
        ## once Parameters are validated
        ## we try to refine them
        ## if any are unrefinable, we toss the params back
        ## if all are good, we convert
        ## how do we validate each field in parameter wrt refinement?

        {:ok, search_info} <- Search.refine(validated_params),
        ## ALT

        ## we could keep more similar to how it is
        ## we validate the SearchInfo post-refinement
        ## and if bad, we convert it back to Parameters to display on UI
         #{:ok, search_info} <- Search.convert(refined_params),
         ## TODO - need to work out how to deal with unrefined results and multiple results
         ## probably use the `else` to drive some view behavior
         ## ask user to try another input or select from the choices, respectively
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
