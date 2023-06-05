defmodule QuickestRoute.Search do
  @moduledoc """
  Defines search context
  """
  alias QuickestRoute.Search.{Google, Parameters, Searcher, SearchInfo}

  @doc """
  Supplies an empty form for view
  """
  def form, do: Parameters.form()

  def validate(params), do: Parameters.validate(params)

  def convert(%Parameters{} = validated_params), do: {:ok, SearchInfo.init(validated_params)}

  def refine(%Parameters{} = parameters), do: Searcher.refine(parameters, Google.get_api_key())

  def search(search_info) do
    search_info
    |> Searcher.search(Google.get_api_key())
    ## TODO - this shouldn't always be :ok
    ## consider moving the tuple creation into `search`
    |> then(&{:ok, &1})
  end
end
