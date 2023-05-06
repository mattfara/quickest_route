defmodule TestStruct do
  defstruct [:a, :b]
end

defmodule PatternHelpersTest do
  use ExUnit.Case

  import PatternHelpers

  doctest PatternHelpers

  describe "pattern_filter/3" do
    test "should safely filters maps" do
      assert 1 == %{a: 1, b: 2} |> pattern_filter(%{a: a, b: 2})

      assert 2 == %{a: 2, b: 2} |> pattern_filter(%{a: a}) |> then(& &1)

      assert 3 == %{a: 3, b: 4} |> pattern_filter(%{b: 4, a: a})
    end

    test "should safely filters nested maps" do
      assert 1 == %{a: %{b: %{c: 1}}} |> pattern_filter(%{a: %{b: %{c: c}}})
    end

    test "should safely filters structs" do
      assert 4 == %TestStruct{a: 4} |> pattern_filter(%{a: x})

      assert 5 == %TestStruct{a: 5} |> pattern_filter(%TestStruct{a: x})
    end

    test "should safely filters lists" do
      assert 1 == [0, 1, 2] |> pattern_filter([0, b, 2])

      assert 2 == [1, 2, 3] |> pattern_filter([_, num, _])

      assert 3 == [a: 1, b: 3] |> pattern_filter(a: 1, b: b)

      assert [4, 5] == [1, 2, 3, 4, 5] |> pattern_filter([1, 2, 3 | rest])
    end

    test "should safely filters tuples" do
      assert 1 == {1, 2, 1} |> pattern_filter({1, 2, c})
    end

    test "should safely filters strings" do
      assert "1" == "a1" |> pattern_filter("a" <> rest)

      assert "" == "a" |> pattern_filter("a" <> rest)
    end

    test "should safely filters a number to itself when the pattern is just a variable" do
      assert 1.1 == 1.1 |> pattern_filter(x)
    end

    test "should returns default when no match" do
      assert nil == Map.new() |> pattern_filter(%{a: a})

      assert "default" == "abc" |> pattern_filter("x" <> rest, "default")
    end

    test "should not re-assign variables outside pipe" do
      x = 0

      "abc" |> pattern_filter("a" <> x)

      assert x == 0
    end

    test "should throw ArgumentError when no variables in pattern" do
      # The error is raised at compile time, so we need to test it in this funky fashion

      assert_raise(ArgumentError, fn ->
        defmodule TempModule do
          import PatternHelpers

          pattern_filter("abc", "a")
        end
      end)
    end

    test "should throw ArgumentError when multiple variables in pattern" do
      # The error is raised at compile time, so we need to test it in this funky fashion

      assert_raise(ArgumentError, fn ->
        defmodule TempModule do
          import PatternHelpers

          pattern_filter("abc", "a" <> x <> y)
        end
      end)
    end
  end

  describe "pattern_filter!/2" do
    test "should filter maps" do
      assert 1 == %{a: 1, b: 2} |> pattern_filter!(%{a: a, b: 2})

      assert 2 == %{a: 2, b: 2} |> pattern_filter!(%{a: a})

      assert 3 == %{a: 3, b: 4} |> pattern_filter!(%{b: 4, a: a})
    end

    test "should filter nested maps" do
      assert 1 == %{a: %{b: %{c: 1}}} |> pattern_filter!(%{a: %{b: %{c: c}}})
    end

    test "should filter structs" do
      assert 4 == %TestStruct{a: 4} |> pattern_filter!(%{a: x})

      assert 5 == %TestStruct{a: 5} |> pattern_filter!(%TestStruct{a: x})
    end

    test "should filter lists" do
      assert 1 == [0, 1, 2] |> pattern_filter!([0, b, 2])

      assert 2 == [1, 2, 3] |> pattern_filter!([_, num, _])

      assert 3 == [a: 1, b: 3] |> pattern_filter!(a: 1, b: b)

      assert [4, 5] == [1, 2, 3, 4, 5] |> pattern_filter!([1, 2, 3 | rest])
    end

    test "should filter tuples" do
      assert 1 == {1, 2, 1} |> pattern_filter!({1, 2, c})
    end

    test "should filter strings" do
      assert "1" == "a1" |> pattern_filter!("a" <> rest)

      assert "" == "a" |> pattern_filter!("a" <> rest)
    end

    test "should filter a number to itself when the pattern is just a variable" do
      assert 1.1 == 1.1 |> pattern_filter!(x)
    end

    test "should not re-assign variables outside pipe" do
      x = 0

      "abc" |> pattern_filter!("a" <> x)

      assert x == 0
    end

    test "should throw MatchError when no match" do
      assert_raise(MatchError, fn ->
        "abc" |> pattern_filter!("x" <> rest)
      end)
    end

    test "should throw ArgumentError when no variables in pattern" do
      # The error is raised at compile time, so we need to test it in this funky fashion

      assert_raise(ArgumentError, fn ->
        defmodule TempModule do
          import PatternHelpers

          pattern_filter!("abc", "a")
        end
      end)
    end

    test "should throw ArgumentError when multiple variables in pattern" do
      # The error is raised at compile time, so we need to test it in this funky fashion

      assert_raise(ArgumentError, fn ->
        defmodule TempModule do
          import PatternHelpers

          pattern_filter!("abc", "a" <> x <> y)
        end
      end)
    end
  end
end
