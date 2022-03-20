defmodule TreasureHunter.Repo.Migrations.CreateTreasureHunterTables do
  use Ecto.Migration

  def change do
    create_mnemonics()
    create_cryptos()
    create_addresses()
  end

  defp create_mnemonics() do
    create table(:mnemonics) do
      add(:mnemonic, :string, null: false)
      add(:type, :string, null: false)

      timestamps()
    end

    create(unique_index(:mnemonics, [:mnemonic, :type]))
  end

  defp create_cryptos() do
    create table(:cryptos) do
      add(:type, :string)

      timestamps()
    end

    create(unique_index(:cryptos, :type))
  end

  defp create_addresses() do
    create table(:addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:crypto_id, references(:cryptos))
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean, null: false, default: false)
      add(:uncompressed, :boolean, null: false, default: false)
      add(:balance, :decimal)
      add(:tx_count, :integer)

      timestamps()
    end

    create(unique_index(:addresses, [:mnemonic_id, :crypto_id, :path, :uncompressed]))
    create(index(:addresses, :checked))
    create(index(:addresses, :balance))
    create(index(:addresses, :tx_count))
  end
end
