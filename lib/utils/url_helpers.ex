defmodule QuickestRoute.UrlHelpers do
  @spec space_to(binary, binary) :: binary
  def space_to(input, to) when is_binary(to), do: String.replace(input, ~r/\s+/, to)
end
