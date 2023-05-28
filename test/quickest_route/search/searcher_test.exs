defmodule QuickestRoute.Search.SearcherTest do
  use ExUnit.Case, async: true
  use Mimic
  doctest QuickestRoute.Search.Searcher
  alias QuickestRoute.Search.{Parameters, Place, Searcher, ApiCaller, SearchInfo}

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

    test "should parse and sort durations from successful API call", %{
      data: data,
      api_key: api_key,
      responses: responses
    } do
      expect(ApiCaller, :call, 2, fn _url -> responses.ok end)

      assert Map.put(data, :search_summary, [
               {data.origin, List.first(data.alternatives), {15, "?"}, nil},
               {data.origin, Enum.at(data.alternatives, 1), {15, "?"}, nil}
             ]) == Searcher.search(data, api_key)
    end

    test "should successfully parse a non-200 response", %{
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

      assert Map.put(data, :search_summary, [
               {data.origin, List.first(data.alternatives), {"?", "?"}, nil},
               {data.origin, Enum.at(data.alternatives, 1), {15, "?"}, nil}
             ]) == Searcher.search(data, api_key)
    end
  end

  describe "refine/1" do
    setup do
      responses = %{
        ok_full_context: %{
          location_a: %{
            "status" => "OK",
            "candidates" => [
              %{
                "name" => "location_a",
                "place_id" => "abc123"
              }
            ]
          },
          location_b: %{
            "status" => "OK",
            "candidates" => [
              %{
                "name" => "location_b",
                "place_id" => "def234"
              }
            ]
          },
          location_c: %{
            "status" => "OK",
            "candidates" => [
              %{
                "name" => "location_c",
                "place_id" => "ghi345"
              }
            ]
          },
          location_d: %{
            "status" => "OK",
            "candidates" => [
              %{
                "name" => "location_d",
                "place_id" => "jkl456"
              }
            ]
          }
        },
        bad: %{}
      }

      data = {:ok, api_key: "xyz", responses: responses}
      expect(ApiCaller, :call, 8, fn url ->
        cond do
          url =~ "abc" ->
            responses.ok_full_context.location_a

          url =~ "def" ->
            responses.ok_full_context.location_b

          url =~ "ghi" ->
            responses.ok_full_context.location_c

          url =~ "jkl" ->
            responses.ok_full_context.location_d
        end
      end)

      data
    end

    test "should refine search including `final_destination` and multiple alternatives into `SearchInfo`",
         %{
           api_key: api_key
         } do
      params = %Parameters{from: "abc", to: ["def", "ghi"], finally: "jkl", departure_time: "now"}

      assert {:ok,
              %QuickestRoute.Search.SearchInfo{
                origin: %QuickestRoute.Search.Place{
                  status: :ok,
                  original: "abc",
                  refined: %{"name" => "location_a", "place_id" => "abc123"},
                  error_message: nil
                },
                departure_time: "now",
                alternatives: [
                  %QuickestRoute.Search.Place{
                    status: :ok,
                    original: "ghi",
                    refined: %{"name" => "location_c", "place_id" => "ghi345"},
                    error_message: nil
                  },
                  %QuickestRoute.Search.Place{
                    status: :ok,
                    original: "def",
                    refined: %{"name" => "location_b", "place_id" => "def234"},
                    error_message: nil
                  }
                ],
                final_destination: %QuickestRoute.Search.Place{
                  status: :ok,
                  original: "jkl",
                  refined: %{"name" => "location_d", "place_id" => "jkl456"},
                  error_message: nil
                },
                search_summary: nil
              }} == Searcher.refine(params, api_key)
    end

    test "should refine search lacking a `final_destination` into `SearchInfo`" do
      flunk("Not implemented")
    end
  end
end
