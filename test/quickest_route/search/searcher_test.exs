defmodule QuickestRoute.Search.SearcherTest do
  use ExUnit.Case, async: true
  use Mimic
  doctest QuickestRoute.Search.Searcher
  alias QuickestRoute.Search.{Place, Searcher, ApiCaller, SearchInfo}

  describe "search/1" do
    setup do
      {:ok,
       data: %SearchInfo{
         origin: %Place{refined: [%{"place_id" => "123"}]},
         alternatives: [
           %Place{refined: [%{"name" => "name1", "place_id" => "456"}]},
           %Place{refined: [%{"name" => "name2", "place_id" => "789"}]}
         ],
         departure_time: "now"
       },
       api_key: "abc",
       responses: %{
         ok: %{
           "status" => "OK",
           "routes" => [%{"legs" => [%{"duration" => %{"text" => "15 mins"}}]}]
         },
         bad: %{}
       }}
    end

    test "parses and sorts durations from successful API call", %{
      data: data,
      api_key: api_key,
      responses: responses
    } do
      expect(ApiCaller, :call, 2, fn _url -> responses.ok end)

      assert Map.put(data, :durations, [
               {data.origin, List.first(data.alternatives), 15},
               {data.origin, Enum.at(data.alternatives, 1), 15}
             ]) == Searcher.search(data, api_key)
    end

    test "Successfully parses a non-200 response", %{
      data: data,
      api_key: api_key,
      responses: responses
    } do
      expect(ApiCaller, :call, 2, fn url ->
        if url =~ "789" do
          responses.ok
        else
          responses.bad
        end
      end)

      assert Map.put(data, :durations, [
               {data.origin, List.first(data.alternatives), "?"},
               {data.origin, Enum.at(data.alternatives, 1), 15}
             ]) == Searcher.search(data, api_key)
    end
  end
end
