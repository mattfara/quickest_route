defmodule QuickestRouteWeb.UserView do
  use QuickestRouteWeb, :view

  alias QuickestRoute.Accounts

  def first_name(%Accounts.User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
