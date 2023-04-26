defmodule QuickestRoute.Search.Parameters do
  @moduledoc """
  Schema for new search form
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required [:from, :to, :departure_time]
  @fields @required
  @primary_key false

  embedded_schema do
    field :from, :string
    field :to, {:array, :string}
    field :departure_time, :string, default: "now"
  end

  @spec form :: Ecto.Changeset.t()
  def form, do: cast(%__MODULE__{}, %{}, @fields)

  @spec changeset(map()) :: Changeset.t()
  defp changeset(attrs),
    do:
      %__MODULE__{}
      |> cast(attrs, @fields)
      |> validate_required(@required)
      |> validate_to()

  @spec validate(map()) :: {:ok, map()} | {:error, Changeset.t()}
  def validate(form) do
    form
    |> changeset()
    |> case do
      %{valid?: true, changes: changes, data: %{departure_time: departure_time}} ->
        {:ok, Map.put(changes, :departure_time, departure_time)}

      changeset ->
        {:error, changeset}
    end
  end

  defp validate_to(%{changes: %{to: []}} = changeset),
    do: add_error(changeset, :to, "must supply at least one destination")

  defp validate_to(changeset), do: changeset
end
