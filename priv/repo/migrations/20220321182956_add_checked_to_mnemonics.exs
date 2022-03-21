defmodule TreasureHunter.Repo.Migrations.AddCheckedToMnemonics do
  use Ecto.Migration

  def change do
    alter table(:mnemonics) do
      add(:checked, :boolean)
    end

    create(index(:mnemonics, :checked))
  end
end
