defmodule QuickestRouteWeb.SearchController do
  use QuickestRouteWeb, :controller

  alias QuickestRoute.Search

  def new(conn, _params) do
    changeset = Search.form()
    render(conn, "new.html", changeset: changeset)
  end

  def run(conn, %{"parameters" => params}) do
    with {:ok, validated_params} <- Search.validate(params),
         ## TODO - need to work out how to deal with unrefined results and multiple results
         ## probably use the `else` to drive some view behavior
         ## ask user to try another input or select from the choices, respectively
         {:ok, refined_params} <- Search.refine(validated_params),
         {:ok, response} <- Search.search(refined_params),
         do:
           conn
           |> put_flash(:info, "Search submitted!")
           |> redirect(to: Routes.search_path(conn, :show, response))
  end

  def show(conn, response) do
    # surprised to learn that the order of the list in the response
    # is not preserved in the redirect
    sorted = Enum.sort_by(response, fn {_name, duration} -> duration end)
    render(conn, "show.html", response: sorted)
  end
end
