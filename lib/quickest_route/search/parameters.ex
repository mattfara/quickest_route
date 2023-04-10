defmodule QuickestRoute.Search.Parameters do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:from, :to]
  @attributes @required
  @primary_key false

  embedded_schema do
    field :from, :string
    field :to, {:array, :string}
  end

  @spec form :: Ecto.Changest.t()
  def form, do: cast(%__MODULE__{}, %{}, @attributes)

  def form(attributes) do
    cast(%__MODULE__{}, attributes, @attributes)
  end

  def attributes(form) do
    applied = apply_action(form, :create)

    case applied do
      {:ok, struct} -> {:ok, Map.from_struct(struct)}
      other -> other
    end
  end

  def changeset(parameters, attrs) do
    parameters
    |> cast(attrs, @attributes)
    |> validate_required(@required)
  end
end
