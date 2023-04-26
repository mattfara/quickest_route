defmodule QuickestRoute.Search.SearchInfo do
  @moduledoc """
  Gathers fields during search for trip durations
  """

  alias QuickestRoute.Search.Place

  defstruct [
    :origin,
    :alternatives,
    :departure_time,
    ## TODO add final destination later for
    ## three-part search
    :durations
  ]

  @type t :: %__MODULE__{
          origin: Place.t(),
          alternatives: list(Place.t()),
          departure_time: String.t(),
          # final_destination: Place.t() | nil,
          durations: [
            tuple()
          ]
        }

  def init(%{from: from, to: [_ | _] = to, departure_time: departure_time}) do
    %__MODULE__{
      origin: from,
      alternatives: to,
      departure_time: departure_time
    }
  end
end
