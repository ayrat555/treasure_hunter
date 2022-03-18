defmodule TreasureHunter.Wallet.Crypto do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @required_fields [:type]

  schema "cryptos" do
    field(:type, Ecto.Enum, values: [:bitcoin])

    timestamps()
  end

  def changeset(crypto, params) do
    crypto
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
