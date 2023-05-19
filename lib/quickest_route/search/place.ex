defmodule QuickestRoute.Search.Place do
  defstruct [
    :status,
    :original,
    :refined,
    :error_message
  ]

  ## TODO - is there room for an OR ADT here wrt status property?

  @type t :: %__MODULE__{
          status: :atom,
          original: String.t(),
          refined: map(),
          error_message: String.t()
        }
end
