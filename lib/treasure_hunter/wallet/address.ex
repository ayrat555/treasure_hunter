defmodule TreasureHunter.Wallet.Address do
  use Ecto.Schema

  import Ecto.Changeset

  alias TreasureHunter.Wallet.Crypto
  alias TreasureHunter.Wallet.Mnemonic

  @type t :: %__MODULE__{}

  @required_fields [:path, :address, :crypto_type, :mnemonic_id]
  @optional_fields [:checked, :used, :balance]

  schema "addresses" do
    field(:path, :string)
    field(:address, :string)
    field(:checked, :boolean)
    field(:used, :boolean)
    field(:balance, :decimal)

    belongs_to(:crypto_type, Crypto, type: :string, references: :type)
    belongs_to(:mnemonic, Mnemonic)

    timestamps()
  end

  def changeset(address, params) do
    address
    |> cast(params, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
