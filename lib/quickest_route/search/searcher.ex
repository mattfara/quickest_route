defmodule QuickestRoute.Search.Searcher do
  alias QuickestRoute.Search.Google
  alias QuickestRoute.{StringHelpers, UrlHelpers}

  @not_found "?"

  defp prepare_to(input),
    do: {
      input,
      UrlHelpers.space_to(input, "+")
    }

  ## TODO rename and move into Google module
  defp parse(
         {:ok,
          {original,
           %{"status" => "OK", "routes" => [%{"legs" => [%{"duration" => %{"text" => text}}]}]}}}
       ),
       do:
         text
         |> String.split(" ")
         |> List.first()
         |> StringHelpers.parse_integer(@not_found)
         |> then(&{original, &1})

  ## TODO rename and move into Google module
  defp parse({:ok, {original, _json}}),
    do: {original, @not_found}

  def search(%{changes: %{from: from, to: [_ | _] = to}}) do
    from = UrlHelpers.space_to(from, "+")

    to
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&prepare_to(&1))
    |> Stream.map(&Google.get_direction_url(from, &1, Google.get_api_key()))
    |> Task.async_stream(&Google.call_api(&1))
    |> Stream.map(&parse(&1))
    |> Enum.sort_by(fn {_, mins} -> mins end)
  end
end
