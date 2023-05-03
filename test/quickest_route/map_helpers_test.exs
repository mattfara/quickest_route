defmodule QuickestRoute.MapHelpersTest do
  use ExUnit.Case
  doctest QuickestRoute.MapHelpers
  alias QuickestRoute.MapHelpers

  describe "get_first/2" do
    test "should get value at first path that matches" do
      map = %{a: %{b: 1}}
      paths = [[:a, :b], [:b, :a]]

      assert 1 == MapHelpers.get_first(map, paths)
    end

    test "should get value at second path if first does not match but second does" do
      map = %{a: %{b: 1}}
      paths = [[:b, :a], [:a, :b]]

      assert 1 == MapHelpers.get_first(map, paths)
    end

    test "should return nil if no paths match" do
      map = %{a: %{b: 1}}
      paths = [[:c]]

      assert nil == MapHelpers.get_first(map, paths)
    end

    test "should return specified default if no paths match" do
      map = %{a: %{b: 1}}
      paths = [[:c]]

      assert "MISSING" == MapHelpers.get_first(map, paths, "MISSING")
    end
  end
end
