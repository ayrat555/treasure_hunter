defmodule TreasureHunter.Application do
  use Application

  def start(_type, _args) do
    children = [
      TreasureHunter.Repo
    ]

    opts = [strategy: :one_for_one, name: TreasureHunter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
