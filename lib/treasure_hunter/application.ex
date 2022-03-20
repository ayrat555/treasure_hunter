defmodule TreasureHunter.Application do
  use Application

  def start(_type, _args) do
    children = [
      TreasureHunter.Repo,
      {Finch, name: TreasureHunter.HTTPClient},
      {Oban, oban_config()}
    ]

    opts = [strategy: :one_for_one, name: TreasureHunter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp oban_config do
    Application.fetch_env!(:treasure_hunter, Oban)
  end
end
