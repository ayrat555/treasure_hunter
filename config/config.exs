import Config

config :treasure_hunter, TreasureHunter.Repo,
  username: "postgres",
  password: "postgres",
  database: "treasure_hunter",
  hostname: "localhost",
  log: false,
  pool_size: 40

config :treasure_hunter,
  ecto_repos: [TreasureHunter.Repo]

config :treasure_hunter, Oban,
  repo: TreasureHunter.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 1]

config :treasure_hunter, TreasureHunter.Worker,
  api_clients: %{
    bitcoin: TreasureHunter.Bitcoin.ExplorerAPI,
    dogecoin: TreasureHunter.Dogecoin.DogecoinAPI,
    tron: TreasureHunter.Tron.TronscanAPI,
    gnosis: TreasureHunter.Gnosis.BlockscoutAPI
  }

import_config "#{Mix.env()}.exs"
