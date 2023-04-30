defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller, Place}
  alias QuickestRoute.{StringHelpers}

  @not_found "?"

  def get_direction_url(
        from_id,
        %Place{refined: [%{"place_id" => to_id} | _]} = to_place,
        api_key,
        "now"
      ) do
    %{
      alternative: to_place,
      direction_url:
        "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:#{from_id}&destination=place_id:#{to_id}&key=#{api_key}"
    }
  end

  def get_direction_url(
        from_id,
        %Place{refined: [%{"place_id" => to_id} | _]} = to_place,
        api_key,
        departure_time
      ) do
    %{
      alternative: to_place,
      direction_url:
        "https://maps.googleapis.com/maps/api/directions/json?departure_time=#{departure_time}&origin=place_id:#{from_id}&destination=place_id:#{to_id}&key=#{api_key}"
    }
  end

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

  @spec get_api_key() :: String.t()
  def get_api_key, do: Application.get_env(:quickest_route, __MODULE__)[:google_api_key]

  @spec parse_directions({:ok, map()}) :: map()
  def parse_directions(
        {:ok,
         %{
           directions: %{
             "status" => "OK",
             "routes" => [%{"legs" => [%{"duration" => %{"text" => text}}] = leg_info}]
           }
         } = intermediate}
      ) do
    duration_string =
      leg_info
      |> List.first()
      |> get_in(["duration_in_traffic", "text"]) ||
        text

    duration_string
    |> String.split(" ")
    |> List.first()
    |> StringHelpers.parse_integer(fallback: @not_found)
    |> then(&Map.put(intermediate, :duration, &1))
  end

  def parse_directions({:ok, place}),
    do: Map.put(place, :duration, @not_found)
end
