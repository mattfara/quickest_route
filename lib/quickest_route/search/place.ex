defmodule QuickestRoute.Search.Place do
  defstruct [
    :status,
    :original,
    :refined,
    :error_message
  ]

  @type t :: %__MODULE__{
          status: :atom,
          original: String.t(),
          refined: map(),
          error_message: String.t()
        }
end
