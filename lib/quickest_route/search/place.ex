defmodule QuickestRoute.Search.Place do
  # purpose of this is to save the general idea of a place:
  # # original user input
  # # refined version(s)

  defstruct [:status, :original, :refined, :error_message]
end
