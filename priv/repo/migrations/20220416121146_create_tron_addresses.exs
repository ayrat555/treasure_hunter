defmodule TreasureHunter.Repo.Migrations.CreateTronAddresses do
  use Ecto.Migration

  def change do
    create table(:tron_addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean, null: false, default: false)
      add(:balance, :jsonb)
      add(:tx_count, :integer)

      timestamps()
    end

    create(unique_index(:tron_addresses, [:mnemonic_id, :path]))
    create(index(:tron_addresses, :checked))
    create(index(:tron_addresses, :balance))
    create(index(:tron_addresses, :tx_count))
  end
end
