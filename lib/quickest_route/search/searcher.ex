defmodule QuickestRoute.Search.Searcher do
  @moduledoc """
  Searches for trip durations to alternative locations
  """
  alias QuickestRoute.Search.{ApiCaller, Google, Place, SearchInfo}

  def search(
        %SearchInfo{
          origin: %Place{refined: [%{"place_id" => from_id}]} = origin,
          alternatives: alternatives,
          departure_time: departure_time,
          final_destination: %Place{refined: [%{"place_id" => final_id}]} = final_destination,
        } = search_info,
        api_key
      ) do
    durations =
      alternatives
      |> Stream.map(&Google.get_direction_url(search_info, &1, api_key))
      |> Task.async_stream(&get_directions(&1))
      |> Stream.map(&Google.parse_route_info(&1)) # this might need to change given waypoint
      |> Enum.map(
        &{
          origin,
          &1.alternative,
          &1.duration
        }
      )

    Map.put(search_info, :durations, durations)
  end

  defp get_directions(%{direction_url: url} = intermediate),
    do: Map.put(intermediate, :directions, ApiCaller.call(url))
end
