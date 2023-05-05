defmodule QuickestRoute.StringHelpersTest do
  use ExUnit.Case
  doctest QuickestRoute.StringHelpers
  alias QuickestRoute.StringHelpers

  @not_int "?"

  describe "parse_integer/1" do
    test "should parse string with one number to integer" do
      assert 1 == StringHelpers.parse_integer("1", fallback: "")
    end

    test "should parse string with three numbers to integer" do
      assert 123 == StringHelpers.parse_integer("123", fallback: "")
    end

    test "should parse string starting with zero to not_int string" do
      assert @not_int == StringHelpers.parse_integer("0123", fallback: @not_int)
    end

    test "should parse non-numeric string to not_int" do
      assert @not_int == StringHelpers.parse_integer("caterpillar", fallback: @not_int)
    end
  end
end
