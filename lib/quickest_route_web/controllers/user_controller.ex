defmodule QuickestRouteWeb.UserController do
  use QuickestRouteWeb, :controller

  alias QuickestRoute.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end
end
