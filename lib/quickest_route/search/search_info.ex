defmodule QuickestRoute.Search.SearchInfo do
  @moduledoc """
  Gathers fields during search for trip durations
  """

  use StructAccess
  ## TODO - really want to use this just for tests? see google_test.exs

  alias QuickestRoute.Search.{Parameters, Place}

  defstruct [
    :origin,
    :departure_time,
    :alternatives,
    :final_destination,
    :search_summary
  ]

  @type t :: %__MODULE__{
          origin: Place.t(),
          departure_time: String.t(),
          alternatives: list(Place.t()),
          final_destination: Place.t(),
          search_summary: [
            tuple()
          ]
        }

  def init(%Parameters{
        from: from,
        to: [_ | _] = to,
        departure_time: departure_time,
        finally: finally
      }) do
    %__MODULE__{
      origin: from,
      departure_time: departure_time,
      alternatives: to,
      final_destination: finally
    }
  end
end
