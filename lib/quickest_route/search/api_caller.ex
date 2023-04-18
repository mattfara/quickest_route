defmodule QuickestRoute.Search.ApiCaller do
  def call(url),
    do:
      url
      |> HTTPoison.get!()
      |> then(& &1.body)
      |> Jason.decode!()
end
