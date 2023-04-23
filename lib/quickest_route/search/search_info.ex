defmodule QuickestRoute.Search.SearchInfo do
  use StructAccess

  alias __MODULE__
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
          alternatives: [Place.t()],
          departure_time: String.t(),
          # final_destination: Place.t() | nil,
          durations: [
            tuple()
          ]
        }

  ## TODO - delete
  @moduledoc """
  [
    [
      {place_1, place_2, duration},
      {place_2, place_4, duration}
    ],
    [
       # etc
      {place_1, place_3, duration}
      {place_3, place_4, duration}
    ]
  ]
  """

  def init(%{from: from, to: to, departure_time: departure_time}) do
    {:ok,
     %SearchInfo{
       origin: from,
       alternatives: to,
       departure_time: departure_time
     }}
  end
end
