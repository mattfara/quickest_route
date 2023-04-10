defmodule QuickestRoute.UrlHelpers do
  def space_to(input, to) when is_binary(to), do: String.replace(input, ~r/\s+/, to)
end
