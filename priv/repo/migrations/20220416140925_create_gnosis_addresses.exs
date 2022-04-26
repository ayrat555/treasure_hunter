defmodule TreasureHunter.Repo.Migrations.CreateGnosisAddresses do
  use Ecto.Migration

  def change do
    create table(:gnosis_addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean, null: false, default: false)
      add(:balance, :jsonb)
      add(:tx_count, :integer)

      timestamps()
    end

    create(unique_index(:gnosis_addresses, [:mnemonic_id, :path]))
    create(index(:gnosis_addresses, :checked))
    create(index(:gnosis_addresses, :balance))
    create(index(:gnosis_addresses, :tx_count))
  end
end
