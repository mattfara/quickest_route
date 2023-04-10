defmodule QuickestRouteWeb.PageController do
  use QuickestRouteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
