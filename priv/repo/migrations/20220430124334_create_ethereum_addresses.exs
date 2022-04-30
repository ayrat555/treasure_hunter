defmodule TreasureHunter.Repo.Migrations.CreateEthereumAddresses do
  use Ecto.Migration

  def change do
    create table(:ethereum_addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean, null: false, default: false)
      add(:balance, :jsonb)
      add(:tx_count, :integer)

      timestamps()
    end

    create(unique_index(:ethereum_addresses, [:mnemonic_id, :path]))
    create(index(:ethereum_addresses, :checked))
    create(index(:ethereum_addresses, :balance))
    create(index(:ethereum_addresses, :tx_count))
  end
end
