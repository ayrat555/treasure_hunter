import Config

config :treasure_hunter, TreasureHunter.Repo,
  username: "postgres",
  password: "postgres",
  database: "treasure_hunter_test",
  hostname: "localhost",
  pool_size: 20,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

config :treasure_hunter, Oban, queues: false, plugins: false

config :treasure_hunter, TreasureHunter.Worker,
  api_clients: %{bitcoin: MockExplorerAPI, dogecoin: MockExplorerAPI}
