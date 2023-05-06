defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller, Place, SearchInfo}
  alias QuickestRoute.MapHelpers
  import PatternHelpers

  @not_found "?"

  def get_direction_url(
        %SearchInfo{
          origin: %Place{refined: [%{"place_id" => from_id}]},
          departure_time: departure_time,
          final_destination: final_destination
        },
        %Place{refined: [%{"place_id" => to_id} | _]} = to_place,
        api_key
      ) do
    ## TODO - refactor this garbage
    url =
      get_base_directions_url() <>
        "?" <> get_origin_query(from_id) <> "&" <> get_api_key_query(api_key) <> "&"

    url =
      if departure_time == "now" do
        url
      else
        url <> get_departure_time_query(departure_time) <> "&"
      end

    url =
      if final_destination do
        url <> get_destination_query(final_destination) <> "&" <> get_waypoint_query(to_id)
      else
        url <> get_destination_query(to_id)
      end

    %{
      alternative: to_place,
      direction_url: url
    }
  end

  defp get_base_directions_url(), do: "https://maps.googleapis.com/maps/api/directions/json"
  defp get_origin_query(place_id), do: "origin=place_id:#{place_id}"

  defp get_destination_query(%Place{refined: [%{"place_id" => place_id}]}),
    do: "destination=place_id:#{place_id}"

  defp get_destination_query(place_id), do: "destination=place_id:#{place_id}"
  defp get_waypoint_query(place_id), do: "waypoints=place_id:#{place_id}"
  defp get_api_key_query(api_key), do: "key=#{api_key}"
  defp get_departure_time_query(departure_time), do: "departure_time=#{departure_time}"

  @doc """
  Retrieves the official name and `place_id` for user input
  """
  def refine_place(nil, _api_key), do: nil

  def refine_place(user_place_name, api_key),
    do:
      user_place_name
      |> get_place_url(api_key)
      |> ApiCaller.call()
      |> parse_place_json(user_place_name)

  defp parse_place_json(%{"status" => "OK", "candidates" => candidates}, place),
    do: %Place{status: :ok, original: place, refined: candidates}

  defp parse_place_json(_, place),
    do: %Place{
      status: :error,
      original: place,
      error_message: "Unable to refine place \"#{place}\" for search"
    }

  @spec get_place_url(place :: String.t(), api_key :: String.t()) :: String.t()
  def get_place_url(place, api_key),
    do:
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cplace_id&input=#{URI.encode(place)}&inputtype=textquery&key=#{api_key}"

  @spec parse_route_info({:ok, map()}) :: map()
  def parse_route_info(
        {:ok,
         %{
           directions: %{
             "status" => "OK",
             "routes" => [%{"legs" => legs}]
           }
         } = intermediate}
      ) do
    duration = sum_leg_property(legs, [["duration_in_traffic", "text"], ["duration", "text"]])
    distance = sum_leg_property(legs, [["distance", "text"]])

    Map.put(intermediate, :route_info, {duration, distance})
  end

  def parse_route_info({:ok, place}),
    do: Map.put(place, :route_info, {@not_found, @not_found}) |> IO.inspect(label: "UNMATCHED")

  defp sum_leg_property(legs, path_alternatives) do
    Enum.reduce(legs, 0, fn leg, acc ->
      leg
      |> MapHelpers.get_first(path_alternatives, "")
      |> Integer.parse()
      |> pattern_filter({x, _}, 0)
      |> Kernel.+(acc)
    end)
    |> case do
      0 -> @not_found
      x -> x
    end
  end

  @spec get_api_key() :: String.t()
  def get_api_key, do: Application.get_env(:quickest_route, __MODULE__)[:google_api_key]
end
