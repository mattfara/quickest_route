defmodule QuickestRoute.Search.Parameters do
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

  def form(attributes) do
    cast(%__MODULE__{}, attributes, @fields)
  end

  def attributes(form) do
    applied = apply_action(form, :create)

    case applied do
      {:ok, struct} -> {:ok, Map.from_struct(struct)}
      other -> other
    end
  end

  def changeset(attrs),
    do:
      %__MODULE__{}
      |> cast(attrs, @fields)
      |> validate_required(@required)
      |> validate_to()

  defp validate_to(%{changes: %{to: []}} = changeset),
    do: add_error(changeset, :to, "must supply at least one destination")

  defp validate_to(changeset), do: changeset
end
