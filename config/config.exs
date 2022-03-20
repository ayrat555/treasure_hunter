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
  queues: [bitcoin: 50]

config :treasure_hunter, Bitcoin, api_client: TreasureHunter.Bitcoin.ExplorerAPI

import_config "#{Mix.env()}.exs"
