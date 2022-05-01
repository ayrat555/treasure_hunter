defmodule TreasureHunter.Repo.Migrations.CreateEthereumClassicAddresses do
  use Ecto.Migration

  def change do
    create table(:ethereum_classic_addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean, null: false, default: false)
      add(:balance, :jsonb)
      add(:tx_count, :integer)

      timestamps()
    end

    create(unique_index(:ethereum_classic_addresses, [:mnemonic_id, :path]))
    create(index(:ethereum_classic_addresses, :checked))
    create(index(:ethereum_classic_addresses, :balance))
    create(index(:ethereum_classic_addresses, :tx_count))
  end
end
