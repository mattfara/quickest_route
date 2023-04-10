defmodule QuickestRoute.StringHelpers do
  @integer ~r/^[1-9]\d*$/
  def parse_integer(x, not_int) when is_binary(x) and is_binary(not_int) do
    if Regex.match?(@integer, x) do
      String.to_integer(x)
    else
      not_int
    end
  end
end
