defmodule TreasureHunter.Repo do
  use Ecto.Repo,
    otp_app: :treasure_hunter,
    adapter: Ecto.Adapters.Postgres
end
