defmodule TreasureHunter.Wallet.EthereumClassicAddress do
  use Ecto.Schema

  import Ecto.Changeset
  alias TreasureHunter.Wallet.Mnemonic

  @type t :: %__MODULE__{}

  @required_fields [:path, :address, :mnemonic_id]
  @optional_fields [:checked, :balance, :tx_count]

  schema "ethereum_classic_addresses" do
    field(:path, :string)
    field(:address, :string)
    field(:checked, :boolean)
    field(:balance, :map)
    field(:tx_count, :integer)

    belongs_to(:mnemonic, Mnemonic)

    timestamps()
  end

  def changeset(address, params) do
    address
    |> cast(params, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
