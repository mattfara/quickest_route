defmodule QuickestRoute.SearchTest do
	use ExUnit.Case
	doctest QuickestRoute.Search
  use Mimic
	alias QuickestRoute.Search
  alias QuickestRoute.Search.{Google, Parameters}


  describe "refine/1" do
    test "can fuck" do
      expect(Google, :get_api_key, fn -> "abc" end)
      expect(Google, :refine_place, 4, fn _a,_b -> "abc" end)

      params = %Parameters{from: "abc", to: ["def", "ghi"], finally: nil, departure_time: "now"}

      Search.refine(params)

    end
  end
end
