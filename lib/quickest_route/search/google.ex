defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """


  def get_direction_url(from, {original, to}, api_key),
    do: {
      original,
      "https://maps.googleapis.com/maps/api/directions/json?origin=#{from}&destination=#{to}&key=#{api_key}"
    }

  def refine_place(place), do: nil

  def get_place_url(place, api_key), do: nil

  def get_api_key, do: Application.get_env(:quickest_route, __MODULE__)[:google_api_key]

  def call_api({original, url}),
    do: {
      original,
      url
      |> HTTPoison.get!()
      |> then(& &1.body)
      |> Jason.decode!()
    }
end
