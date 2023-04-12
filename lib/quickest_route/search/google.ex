defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller,Place}

  def get_direction_url(from, {original, to}, api_key),
    do: {
      original,
      "https://maps.googleapis.com/maps/api/directions/json?origin=#{from}&destination=#{to}&key=#{api_key}"
    }

  def call_api({original, url}),
    do: {
      original,
      ApiCaller.call(url)
    }

  def refine_place(place, api_key),
    do:
      place
      |> get_place_url(api_key)
      |> ApiCaller.call()
      |> parse_place_json(place)

  def parse_place_json(%{"status" => "OK", "candidates" => candidates}, place),
    do: %Place{status: :ok, original: place, refined: candidates}

  def parse_place_json(_, place),
    do: %Place{status: :error, original: place, error_message: "Unable to refine place \"#{place}\" for search"}

  def get_place_url(place, api_key),
    do:
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cplace_id&input=#{URI.encode(place)}&inputtype=textquery&key=#{api_key}"

  def get_api_key, do: Application.get_env(:quickest_route, __MODULE__)[:google_api_key]

end
