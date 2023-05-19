defmodule QuickestRoute.SearchTest do
	use ExUnit.Case
	doctest QuickestRoute.Search
  use Mimic
	alias QuickestRoute.Search
  alias QuickestRoute.Search.{Google, Parameters, Place}


  describe "refine/1" do
    test "should refine multiple places into `SearchInfo`" do
      expect(Google, :get_api_key, fn -> "abc" end)
      expect(Google, :refine_place, 4, fn _a,_b -> {:from, %Place{status: :ok, original: "abc", refined: %{}}} end)

      params = %Parameters{from: "abc", to: ["def", "ghi"], finally: nil, departure_time: "now"}

      Search.refine(params) |> IO.inspect

    end
  end
end
