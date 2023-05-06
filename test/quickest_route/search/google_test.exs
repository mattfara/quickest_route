defmodule QuickestRoute.Search.GoogleTest do
  use ExUnit.Case
  doctest QuickestRoute.Search.Google
  alias QuickestRoute.Search.{ApiCaller, Google, Place, SearchInfo}
  use Mimic.DSL

  describe "get_direction_url/3" do
    setup do
      origin = %Place{refined: [%{"place_id" => "from"}]}

      search_info = %SearchInfo{
        origin: origin,
        departure_time: "now",
        final_destination: nil
      }

      {:ok,
       search_info: search_info, to: %Place{refined: [%{"place_id" => "ghi"}]}, api_key: "jkl"}
    end

    test "should create url properly when searching for departure right now (unspecified departure time)",
         context do
      expected = %{
        alternative: context.to,
        direction_url:
          "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:from&key=jkl&destination=place_id:ghi"
      }

      assert expected ==
               Google.get_direction_url(context.search_info, context.to, context.api_key)
    end

    test "should create url properly when searching for departure at specific datetime",
         context do
      context = put_in(context, [:search_info, :departure_time], "2023-04-20T15:02")

      expected = %{
        alternative: context.to,
        direction_url:
          "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:from&key=jkl&departure_time=2023-04-20T15:02&destination=place_id:ghi"
      }

      assert expected ==
               Google.get_direction_url(context.search_info, context.to, context.api_key)
    end

    test "should create url properly when final destination is used", context do
      final_destination = %Place{refined: [%{"place_id" => "finally"}]}
      context = put_in(context, [:search_info, :final_destination], final_destination)

      expected = %{
        alternative: context.to,
        direction_url:
          "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:from&key=jkl&destination=place_id:finally&waypoints=place_id:ghi"
      }

      assert expected ==
               Google.get_direction_url(context.search_info, context.to, context.api_key)
    end
  end

  describe "get_place_url/2" do
    test "should create url properly for place" do
      place = "I wanna go here"
      api_key = "abc123"

      expected =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cplace_id&input=I%20wanna%20go%20here&inputtype=textquery&key=abc123"

      assert expected == Google.get_place_url(place, api_key)
    end
  end

  describe "refine_place/2" do
    test "should return an Place with status = ok when proper json returned" do
      expected_candidates = [
        %{"name" => "the name", "place_id" => "the id"}
      ]

      ok_json = %{
        "status" => "OK",
        "candidates" => expected_candidates
      }

      expect(ApiCaller.call(_url), do: ok_json)

      place = "user input"

      assert %Place{status: :ok, original: ^place, refined: ^expected_candidates} =
               Google.refine_place(place, "abc")
    end

    test "should return a Place with status = :error when non-200 json returned" do
      bad_json = %{
        "status" => "NOT_OK",
        "candidates" => []
      }

      expect(ApiCaller.call(_url), do: bad_json)

      place = "user input"

      assert %Place{
               status: :error,
               original: ^place,
               error_message: "Unable to refine place \"user input\" for search"
             } = Google.refine_place(place, "abc")
    end
  end

  describe "parse_route_info/1" do
    test "should take duration if available" do
      intermediate = %{
        directions: %{
          "status" => "OK",
          "routes" => [%{"legs" => [%{"duration" => %{"text" => "23 minutes"}}]}]
        }
      }

      direction_json = {:ok, intermediate}

      assert Map.put(intermediate, :route_info, {23, "?"}) ==
               Google.parse_route_info(direction_json)
    end

    test "should take duration_in_traffic over duration if available" do
      intermediate = %{
        directions: %{
          "status" => "OK",
          "routes" => [
            %{
              "legs" => [
                %{
                  "duration" => %{"text" => "23 minutes"},
                  "duration_in_traffic" => %{"text" => "22 minutes"}
                }
              ]
            }
          ]
        }
      }

      direction_json = {:ok, intermediate}

      assert Map.put(intermediate, :route_info, {22, "?"}) ==
               Google.parse_route_info(direction_json)
    end

    test "should take sum of durations if multiple available" do
      intermediate = %{
        directions: %{
          "status" => "OK",
          "routes" => [
            %{
              "legs" => [
                %{"duration" => %{"text" => "23 minutes"}},
                %{"duration" => %{"text" => "23 minutes"}}
              ]
            }
          ]
        }
      }

      direction_json = {:ok, intermediate}

      assert Map.put(intermediate, :route_info, {46, "?"}) ==
               Google.parse_route_info(direction_json)
    end

    test "should return a `?` if cannot parse route info" do
      intermediate = %{
        directions: %{
          "status" => "OK",
          "routes" => "DUD"
        }
      }

      direction_json = {:ok, intermediate}

      assert Map.put(intermediate, :route_info, {"?", "?"}) ==
               Google.parse_route_info(direction_json)
    end
  end
end
