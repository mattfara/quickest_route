defmodule QuickestRoute.Search.SearcherTest do
  use ExUnit.Case, async: true
  use Mimic.DSL
  doctest QuickestRoute.Search.Searcher
  alias QuickestRoute.Search.{Google, Searcher}

  describe "search/1" do
    setup do
      {:ok,
       route_1: "456",
       route_2: "789",
       parameters: %{
         changes: %{
           from: "123",
           to: ["456", "789"]
         }
       }}
    end

    test "parses and sorts durations from successful API call", %{
      route_1: route_1,
      route_2: route_2,
      parameters: parameters
    } do
      expect(Google.call_api({^route_1, _}),
        do:
          {"456",
           %{
             "status" => "OK",
             "routes" => [%{"legs" => [%{"duration" => %{"text" => "15 mins"}}]}]
           }}
      )

      expect(Google.call_api({^route_2, _}),
        do:
          {"789",
           %{
             "status" => "OK",
             "routes" => [%{"legs" => [%{"duration" => %{"text" => "17 mins"}}]}]
           }}
      )

      assert [{^route_1, 15}, {^route_2, 17}] = Searcher.search(parameters)
    end

    test "Successfully parses a non-200 response", %{
      route_1: route_1,
      route_2: route_2,
      parameters: parameters
    } do
      expect(Google.call_api({^route_1, _}),
        do: {"456", %{"status" => "NOT_OK", "key" => "value"}}
      )

      expect(Google.call_api({^route_2, _}),
        do:
          {"789",
           %{
             "status" => "OK",
             "routes" => [%{"legs" => [%{"duration" => %{"text" => "17 mins"}}]}]
           }}
      )

      assert [{^route_2, 17}, {^route_1, "?"}] = Searcher.search(parameters)
    end

    test "Successfully parses a non-200 response and 200 w/ bad data", %{
      route_1: route_1,
      route_2: route_2,
      parameters: parameters
    } do
      expect(Google.call_api({^route_1, _}),
        do: {"456", %{"status" => "NOT_OK", "key" => "value"}}
      )

      expect(Google.call_api({^route_2, _}),
        do:
          {"789",
           %{
             "status" => "OK",
             "routes" => [%{"legs" => [%{"duration" => %{"text" => "no_mins"}}]}]
           }}
      )

      assert [{_, "?"}, {_, "?"}] = Searcher.search(parameters)
    end
  end
end
