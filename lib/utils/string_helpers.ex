defmodule QuickestRoute.StringHelpers do
  @integer ~r/^[1-9]\d*$/

  def parse_integer(str, fallback: fallback) do
    if Regex.match?(@integer, str) do
      String.to_integer(str)
    else
      fallback
    end
  end
end
