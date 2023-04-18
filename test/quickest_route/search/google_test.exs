defmodule QuickestRoute.Search.GoogleTest do
  use ExUnit.Case
  doctest QuickestRoute.Search.Google
  alias QuickestRoute.Search.{ApiCaller, Google, Place}
  use Mimic.DSL

  describe "get_direction_url/3" do
    test "creates url properly" do
      from_place_id = "from"
      to_place = %Place{refined: [%{"place_id" => "ghi"}]}
      api_key = "jkl"

      expected =
        "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:from&destination=place_id:ghi&key=jkl"

      assert Map.put(to_place, :direction_url, expected) == Google.get_direction_url(from_place_id, to_place, api_key)
    end
  end

  describe "get_place_url/2" do
    test "creates url properly" do
      place = "I wanna go here"
      api_key = "abc123"

      expected =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cplace_id&input=I%20wanna%20go%20here&inputtype=textquery&key=abc123"

      assert expected = Google.get_place_url(place, api_key)
    end
  end

  describe "refine_place/2" do
    test "returns an :ok Place when proper json returned" do
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

    test "retuns an :error Place when non-200 json returned" do
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
end
