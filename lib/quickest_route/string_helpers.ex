defmodule QuickestRoute.StringHelpers do
  @integer ~r/^[1-9]\d*$/

  @spec parse_integer(binary, [{:fallback, binary}, ...]) :: any()
  def parse_integer(str, fallback: not_int) when is_binary(str) do
    if Regex.match?(@integer, str) do
      String.to_integer(str)
    else
      not_int
    end
  end
end
