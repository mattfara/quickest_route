defmodule QuickestRouteWeb.SearchView do
  use QuickestRouteWeb, :view

  alias QuickestRoute.Search.Place

  def get_place_name(%Place{refined: [%{"name" => name}]}), do: name
end
