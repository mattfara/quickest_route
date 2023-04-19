defmodule QuickestRoute.Search.Searcher do
  alias QuickestRoute.Search.{ApiCaller, Google, Place}

  def search(
        %{
          from: %Place{refined: [%{"place_id" => from_id}]},
          to: [_ | _] = to
        },
        api_key
      ) do
    to
    |> Stream.map(&Google.get_direction_url(from_id, &1, api_key))
    |> Task.async_stream(&get_directions(&1))
    |> Stream.map(&Google.parse_directions(&1))
    |> Enum.sort_by(fn place -> place.duration end)
    # TODO-  eventually should have the view parse a Place
    # rather than using this tuple
    |> Enum.map(
      &{
        get_place_name(&1),
        &1.duration
      }
    )
  end

  def get_directions(%Place{direction_url: url} = place),
    do: Map.put(place, :directions, ApiCaller.call(url))

  def get_place_name(%Place{refined: [%{"name" => name}]}), do: name
end
