defmodule QuickestRoute.Repo do
  use Ecto.Repo,
    otp_app: :quickest_route,
    adapter: Ecto.Adapters.Postgres
end
