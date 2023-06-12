defmodule QuickestRoute.Search.Parameters do
  @moduledoc """
  Embedded Ecto schema for new search form
  """
  alias Ecto.Changeset

  use Ecto.Schema
  import Ecto.Changeset

  @required [:from, :to, :departure_time]
  @fields @required ++ [:finally]
  @primary_key false

  embedded_schema do
    field :from, :string
    field :departure_time, :string, default: "now"
    field :to, {:array, :string}
    field :finally, :string
  end

  @spec form :: Ecto.Changeset.t()
  def form, do: cast(%__MODULE__{}, %{}, @fields)

  @spec validate(map()) :: {:ok, map()} | {:error, Changeset.t()}
  def validate(form) do
    form
    |> changeset()
    |> apply_action(:validate)
    |> case do
      {:ok, %__MODULE__{}} = parameters -> parameters
      {:error, %Changeset{}} = error -> error
    end
  end

  @spec changeset(map()) :: Changeset.t()
  defp changeset(attrs),
    do:
      %__MODULE__{}
      |> cast(attrs, @fields)
      |> validate_required(@required)
      |> validate_to()

  defp validate_to(%{changes: %{to: []}} = changeset),
    do: add_error(changeset, :to, "must supply at least one destination")

  defp validate_to(changeset), do: changeset
end
