[
  QuickestRoute.Search.Google
]
|> Enum.each(&Mimic.copy(&1))

{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(QuickestRoute.Repo, :manual)
