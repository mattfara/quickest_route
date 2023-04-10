defmodule QuickestRoute.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :username, :string

    timestamps()
  end
end
