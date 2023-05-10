defmodule QuickestRouteWeb.Fallback.FallbackController do
  use QuickestRouteWeb, :controller
  require Logger

  alias Ecto.Changeset

  def call(conn, {:error, %Changeset{} = changeset}) do
    render(conn, "new.html", changeset: changeset)
  end
end
