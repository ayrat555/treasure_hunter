defmodule TreasureHunter.Repo.Migrations.CreateDogecoinAddresses do
  use Ecto.Migration

  def up do
    create_dogecoin_addresses()

    remove_cryptos_table()
  end

  def down do
    drop(table(:dogecoin_addresses))
  end

  defp create_dogecoin_addresses do
    create table(:dogecoin_addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean, null: false, default: false)
      add(:uncompressed, :boolean, null: false, default: false)
      add(:balance, :decimal)
      add(:tx_count, :integer)

      timestamps()
    end

    create(unique_index(:dogecoin_addresses, [:mnemonic_id, :path, :uncompressed]))
    create(index(:dogecoin_addresses, :checked))
    create(index(:dogecoin_addresses, :balance))
    create(index(:dogecoin_addresses, :tx_count))
  end

  defp remove_cryptos_table do
    drop(unique_index(:addresses, [:mnemonic_id, :crypto_id, :path, :uncompressed]))

    alter table(:addresses) do
      remove(:crypto_id)
    end

    drop(table(:cryptos))

    create(unique_index(:addresses, [:mnemonic_id, :path, :uncompressed]))
  end
end
