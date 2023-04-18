defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller, Place}
  alias QuickestRoute.{StringHelpers}

  @not_found "?"

  ## TODO - maybe return the url in a tuple or map so we don't pollute the struct with unnecessary info
  def get_direction_url(
        from_id,
        %Place{refined: [%{"place_id" => to_id} | _]} = to_place,
        api_key
      ) do
    Map.put(
      to_place,
      :direction_url,
      "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:#{from_id}&destination=place_id:#{to_id}&key=#{api_key}"
    )
  end

  @doc """
  Retrieves the official name and `place_id` for user input
  """
  def refine_place(place, api_key),
    do:
      place
      |> get_place_url(api_key)
      |> ApiCaller.call()
      |> parse_place_json(place)

  def parse_place_json(%{"status" => "OK", "candidates" => candidates}, place),
    do: %Place{status: :ok, original: place, refined: candidates}

  def parse_place_json(_, place),
    do: %Place{
      status: :error,
      original: place,
      error_message: "Unable to refine place \"#{place}\" for search"
    }

  def get_place_url(place, api_key),
    do:
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cplace_id&input=#{URI.encode(place)}&inputtype=textquery&key=#{api_key}"

  def get_api_key, do: Application.get_env(:quickest_route, __MODULE__)[:google_api_key]

  def parse_directions(
         {:ok,
          %Place{
            directions: %{
              "status" => "OK",
              "routes" => [%{"legs" => [%{"duration" => %{"text" => text}}]}]
            }
          } = to_place}
       ) do
    text
    |> String.split(" ")
    |> List.first()
    ## TODO pass in an option here for the not found for clarity
    |> StringHelpers.parse_integer(@not_found)
    |> then(&Map.put(to_place, :duration, &1))
  end

  def parse_directions({:ok, place}),
    do: Map.put(place, :duration, @not_found)

end
