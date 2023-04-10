defmodule QuickestRouteWeb.PageControllerTest do
  use QuickestRouteWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Quickest Route"
  end
end
