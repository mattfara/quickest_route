defmodule QuickestRoute.Search.GoogleTest do
  use ExUnit.Case
  doctest QuickestRoute.Search.Google
  alias QuickestRoute.Search.Google

  describe "get_url/3" do
    test "creates url properly" do
      from = "from"
      original = "original_to"
      to = "ghi"
      api_key = "jkl"

      expected =
        "https://maps.googleapis.com/maps/api/directions/json?origin=from&destination=ghi&key=jkl"

      assert {"original_to", expected} == Google.get_url(from, {original, to}, api_key)
    end
  end
end
