defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller, Place, SearchInfo}
  alias QuickestRoute.MapHelpers
  import PatternHelpers

  @not_found "?"

  def get_direction_url(
        search_info,
        %Place{refined: [%{"place_id" => to_id} | _]} = to_place,
        api_key
      ) do
    builders = [
      &get_origin_query/1,
      &get_departure_time_query/1,
      curry_destination_query(to_id)
    ]

    dynamic =
      builders
      |> Enum.map(fn builder -> builder.(search_info) end)
      |> Enum.filter(fn str -> str != "" end)
      |> Enum.join("&")

    %{
      alternative: to_place,
      direction_url: get_base_directions_url(api_key) <> dynamic
    }
  end

  defp get_base_directions_url(api_key),
    do: "https://maps.googleapis.com/maps/api/directions/json?key=#{api_key}&"

  defp get_origin_query(%SearchInfo{origin: %Place{refined: [%{"place_id" => place_id}]}}),
    do: "origin=place_id:#{place_id}"

  defp get_departure_time_query(%SearchInfo{departure_time: "now"}), do: ""

  defp get_departure_time_query(%SearchInfo{departure_time: departure_time}),
    do: "departure_time=#{departure_time}"

  # curry this? build FN with to_id then return FN that takes the search info
  defp curry_destination_query(to_id) do
    fn
      %SearchInfo{final_destination: nil} ->
        "destination=place_id:#{to_id}"

      %SearchInfo{final_destination: %Place{refined: [%{"place_id" => place_id}]}} ->
        "destination=place_id:#{place_id}&waypoints=place_id:#{to_id}"
    end
  end

  # defp get_destination_query(%Place{refined: [%{"place_id" => place_id}]}),
  #  do: "destination=place_id:#{place_id}"

  # defp get_destination_query(place_id), do: "destination=place_id:#{place_id}"

  @doc """
  Retrieves the official name and `place_id` for user input
  """
  def refine_place({:finally, nil}, _api_key), do: {:finally, nil}

  def refine_place({atom, value}, api_key) when atom in [:from, :to, :finally],
    do:
      value
      |> get_place_url(api_key)
      |> ApiCaller.call()
      |> parse_place_json(atom, value)

  ## TODO - have to handle cases where multiple options are returned - maybe show
  ## user the options and let them pick
  defp parse_place_json(%{"status" => "OK", "candidates" => candidates}, atom, value),
    do: {atom, %Place{status: :ok, original: value, refined: candidates}}

  defp parse_place_json(_, atom, value),
    do: {atom, %Place{
      status: :error,
      original: value,
      error_message: "Unable to refine place \"#{value}\" for search"
    }}

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
    do: Map.put(place, :route_info, {@not_found, @not_found})

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
