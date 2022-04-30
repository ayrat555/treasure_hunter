defmodule TreasureHunter.MixProject do
  use Mix.Project

  def project do
    [
      app: :treasure_hunter,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TreasureHunter.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cryptopunk, "~> 0.5"},
      {:ex_rated, "~> 2.0"},
      {:ecto, "~> 3.7"},
      {:ecto_sql, "~> 3.0"},
      {:finch, "~> 0.11"},
      {:oban, "~> 2.11"},
      {:postgrex, ">= 0.0.0"},
      {:sage, "~> 0.6"},
      {:ex_machina, "~> 2.7.0", only: [:test]},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp elixirc_paths(:test),
    do: ["lib", "test/support"]

  defp elixirc_paths(_), do: ["lib"]
end
