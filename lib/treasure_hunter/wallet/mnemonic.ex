defmodule TreasureHunter.Wallet.Mnemonic do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @required_fields [:mnemonic, :type]
  @optional_fields [:checked]

  schema "mnemonics" do
    field(:mnemonic, :string)
    field(:type, Ecto.Enum, values: [:bip39, :slip39, :electrum])
    field(:checked, :boolean)

    timestamps()
  end

  def changeset(mnemonic, params) do
    mnemonic
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:mnemonic, :type])
  end
end
