defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller, Place, SearchInfo}
  alias QuickestRoute.MapHelpers
  import PatternHelpers

  @not_found "?"

  @spec get_api_key() :: String.t()
  def get_api_key, do: Application.get_env(:quickest_route, __MODULE__)[:google_api_key]

  ##################################
  # Google Directions API functions
  ##################################

  @doc """
  Constructs URL to call Google Directions API from `SearchInfo` parameters
  """
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

    %{
      alternative: to_place,
      direction_url:
        get_base_directions_url(api_key) <> get_dynamic_url_fragment(search_info, builders)
    }
  end

  defp get_dynamic_url_fragment(search_info, [_ | _] = builders) do
    builders
    |> Enum.map(fn builder -> builder.(search_info) end)
    |> Enum.filter(fn str -> str != "" end)
    |> Enum.join("&")
  end

  defp get_base_directions_url(api_key),
    do: "https://maps.googleapis.com/maps/api/directions/json?key=#{api_key}&"

  defp get_origin_query(%SearchInfo{origin: %Place{refined: [%{"place_id" => place_id}]}}),
    do: "origin=place_id:#{place_id}"

  defp get_departure_time_query(%SearchInfo{departure_time: "now"}), do: ""

  defp get_departure_time_query(%SearchInfo{departure_time: departure_time}),
    do: "departure_time=#{departure_time}"

  # URL should vary depending on whether user supplied a final destination
  defp curry_destination_query(to_id) do
    fn
      %SearchInfo{final_destination: nil} ->
        "destination=place_id:#{to_id}"

      %SearchInfo{final_destination: %Place{refined: [%{"place_id" => place_id}]}} ->
        "destination=place_id:#{place_id}&waypoints=place_id:#{to_id}"
    end
  end

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
    legs
    |> Enum.reduce(0, fn leg, acc ->
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

  #################################
  # Google Place API functions
  #################################

  @doc """
  Retrieves the official name and `place_id` for user input
  """
  def refine_place({:finally, nil}, _api_key), do: {:finally, %Place{status: :unused}}

  def refine_place({place_context, user_input}, api_key)
      when place_context in [:from, :to, :finally],
      do:
        user_input
        |> get_place_url(api_key)
        |> ApiCaller.call()
        |> parse_place_json(place_context, user_input)

  ## TODO - have to handle cases where multiple options are returned - maybe show
  ## user the options and let them pick
  defp parse_place_json(%{"status" => "OK", "candidates" => candidates}, atom, value),
    do: {atom, %Place{status: :ok, original: value, refined: candidates}}

  defp parse_place_json(_, atom, value),
    do:
      {atom,
       %Place{
         status: :error,
         original: value,
         error_message: "Unable to refine place \"#{value}\" for search"
       }}

  @spec get_place_url(place :: String.t(), api_key :: String.t()) :: String.t()
  def get_place_url(nil, _api_key), do: nil

  def get_place_url(place, api_key),
    do:
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cplace_id&input=#{URI.encode(place)}&inputtype=textquery&key=#{api_key}"
end
