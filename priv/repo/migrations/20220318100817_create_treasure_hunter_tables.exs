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
    create table(:cryptos, primary_key: false) do
      add(:type, :string, primary_key: true)

      timestamps()
    end
  end

  defp create_addresses() do
    create table(:addresses) do
      add(:path, :string, null: false)
      add(:address, :string, null: false)
      add(:crypto_type, references(:cryptos, type: :string, column: :type))
      add(:mnemonic_id, references(:mnemonics))

      add(:checked, :boolean)
      add(:used, :boolean)
      add(:balance, :decimal)

      timestamps()
    end

    create(unique_index(:addresses, [:mnemonic_id, :crypto_type, :path]))
    create(index(:addresses, :checked))
    create(index(:addresses, :used))
    create(index(:addresses, :balance))
  end
end
