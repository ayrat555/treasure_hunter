import Config

config :treasure_hunter, TreasureHunter.Repo,
  username: "postgres",
  password: "postgres",
  database: "treasure_hunter",
  hostname: "localhost"

config :treasure_hunter,
  ecto_repos: [TreasureHunter.Repo]

config :treasure_hunter, Oban,
  repo: TreasureHunter.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [bitcoin: 5]

import_config "#{Mix.env()}.exs"
