defmodule QuickestRoute.Search.Place do
  alias __MODULE__

  use StructAccess
  defstruct [:status, :original, :refined, :error_message, :direction_url, :directions]

  defimpl Inspect do
    def inspect(%Place{} = p, opts) do
      p
      |> Map.put(:direction_url, "***")
      |> Inspect.Any.inspect(opts)
    end
  end
end
