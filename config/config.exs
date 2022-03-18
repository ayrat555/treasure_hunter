import Config

config :treasure_hunter, TreasureHunter.Repo,
  username: "postgres",
  password: "postgres",
  database: "treasure_hunter",
  hostname: "localhost"

config :treasure_hunter,
  ecto_repos: [TreasureHunter.Repo]
