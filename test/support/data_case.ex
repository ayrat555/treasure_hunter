defmodule TreasureHunter.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias TreasureHunter.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import TreasureHunter.DataCase
      import TreasureHunter.Factory
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TreasureHunter.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(TreasureHunter.Repo, {:shared, self()})
    end

    :ok
  end
end
