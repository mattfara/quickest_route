defmodule QuickestRoute.Search.SearchInfo do
  @moduledoc """
  Gathers fields during search for trip durations
  """

  alias QuickestRoute.Search.Place

  defstruct [
    :origin,
    :departure_time,
    :alternatives,
    :final_destination,
    :durations
  ]

  @type t :: %__MODULE__{
          origin: Place.t(),
          departure_time: String.t(),
          alternatives: list(Place.t()),
          final_destination: Place.t(),
          durations: [
            tuple()
          ]
        }

  def init(%{from: from, to: [_ | _] = to, departure_time: departure_time, finally: finally}) do
    %__MODULE__{
      origin: from,
      departure_time: departure_time,
      alternatives: to,
      final_destination: finally
    }
  end
end
