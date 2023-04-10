defmodule QuickestRoute.UrlHelpersTest do
  use ExUnit.Case
  doctest QuickestRoute.UrlHelpers
  alias QuickestRoute.UrlHelpers

  describe "space_to_plus/1" do
    test "replaces a space with a plus" do
      assert "a+b+c" == UrlHelpers.space_to("a b c", "+")
    end

    test "replaces multiple spaces with a plus" do
      assert "a+b+c" == UrlHelpers.space_to("a   b          c", "+")
    end
  end
end
