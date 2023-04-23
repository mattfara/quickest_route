defmodule QuickestRoute.Search.Searcher do
  alias QuickestRoute.Search.{ApiCaller, Google, Place, SearchInfo}

  def search(
        %SearchInfo{
          origin: %Place{refined: [%{"place_id" => from_id}]} = origin,
          alternatives: alternatives,
          departure_time: departure_time
        } = search_info,
        api_key
      ) do
    durations =
      alternatives
      |> Stream.map(&Google.get_direction_url(from_id, &1, api_key, departure_time))
      |> Task.async_stream(&get_directions(&1))
      |> Stream.map(&Google.parse_directions(&1))
      |> Enum.map(
        &{
          origin,
          &1.alternative,
          &1.duration
        }
      )

    Map.put(search_info, :durations, durations)
  end

  def get_directions(%{direction_url: url} = intermediate),
    do: Map.put(intermediate, :directions, ApiCaller.call(url))

  def get_place_name(%{alternative: %Place{refined: [%{"name" => name}]}}), do: name
end
