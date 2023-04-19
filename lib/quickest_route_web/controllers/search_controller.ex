defmodule QuickestRouteWeb.SearchController do
  use QuickestRouteWeb, :controller

  alias QuickestRoute.Search

  def new(conn, _params) do
    changeset = Search.form()
    render(conn, "new.html", changeset: changeset)
  end

  def run(conn, %{"parameters" => params}) do
    form = Search.form(params)

    with {:ok, attributes} <- Search.attributes(form),
         ## TODO - need to work out how to deal with unrefined results and multiple results
         ## probably use the `else` to drive some view behavior
         ## ask user to try another input or select from the choices, respectively
         {:ok, parameters} <- Search.refine(attributes),
         {:ok, response} <- Search.search(parameters),
         do:
           conn
           |> put_flash(:info, "Search submitted!")
           |> redirect(to: Routes.search_path(conn, :show, response))
  end

  def show(conn, response) do
    render(conn, "show.html", response: response)
  end
end
