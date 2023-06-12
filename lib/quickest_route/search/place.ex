defmodule QuickestRoute.Search.Place do
  defstruct [
    :status,
    :original,
    :refined,
    :error_message
  ]

  @type status :: :ok | :unused | :error

  @type t :: %__MODULE__{
          status: status,
          original: String.t(),
          refined: map(),
          error_message: String.t()
        }
end
