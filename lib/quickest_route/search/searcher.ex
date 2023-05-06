defmodule QuickestRoute.Search.Searcher do
  @moduledoc """
  Searches for trip durations to alternative locations
  """
  alias QuickestRoute.Search.{ApiCaller, Google, SearchInfo}

  def search(
        %SearchInfo{
          origin: origin,
          alternatives: alternatives
        } = search_info,
        api_key
      ) do
    search_summary =
      alternatives
      |> Stream.map(&Google.get_direction_url(search_info, &1, api_key))
      |> Task.async_stream(&get_directions(&1))
      |> Stream.map(&Google.parse_route_info(&1))
      |> Enum.map(
        &{
          origin,
          &1.alternative,
          &1.route_info,
          search_info[:final_destination]
        }
      )

    Map.put(search_info, :search_summary, search_summary)
  end

  defp get_directions(%{direction_url: url} = intermediate),
    do: Map.put(intermediate, :directions, ApiCaller.call(url))
end
