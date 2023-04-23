defmodule QuickestRoute.Search.Google do
  @moduledoc """
  Calls the Google Maps Directions API
  """

  alias QuickestRoute.Search.{ApiCaller, Place}
  alias QuickestRoute.{StringHelpers}

  @not_found "?"

  ## TODO - maybe return the url in a tuple or map so we don't pollute the struct with unnecessary info
  ## TODO - maybe better to pass in something like a SearchRequest object which stores the from
  ## and the departure time, etc

  def get_direction_url(
        from_id,
        %Place{refined: [%{"place_id" => to_id} | _]} = to_place,
        api_key,
        departure_time
      ) do
    ## TODO - don't want to waste API $$ by including departure_time when it isn't needed
    url =
      if departure_time == "now" do
        "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:#{from_id}&destination=place_id:#{to_id}&key=#{api_key}"
      else
        "https://maps.googleapis.com/maps/api/directions/json?departure_time=#{departure_time}&origin=place_id:#{from_id}&destination=place_id:#{to_id}&key=#{api_key}"
      end

    # intermediate to carry transient info
    %{
      alternative: to_place,
      direction_url: url
    }
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
    ## TODO pass in an option here for the not found for clarity
    |> StringHelpers.parse_integer(@not_found)
    |> then(&Map.put(intermediate, :duration, &1))
  end

  def parse_directions({:ok, place}),
    do: Map.put(place, :duration, @not_found)
end
