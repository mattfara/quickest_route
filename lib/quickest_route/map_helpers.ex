defmodule QuickestRoute.MapHelpers do
  @doc """
  Returns the first value of a path of keys that match a map or default.

  iex> QuickestRoute.MapHelpers.get_first(%{a: %{b: 1}}, [[:a, :b], [:c, :d, :e]])
  1
  """
  def get_first(map, paths, default \\ nil) do
    Enum.reduce_while(paths, default, fn path, acc ->
      value = get_in(map, path)
      if value != nil, do: {:halt, value}, else: {:cont, acc}
    end)
  end

  ## TODO - how can I apply to a k/v pair in a nested map, based on the following:
  ### key
  ### predicate -> true for value
  ### surrounding context
  
end
