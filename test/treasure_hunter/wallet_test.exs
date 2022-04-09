defmodule TreasureHunter.WalletTest do
  use TreasureHunter.DataCase

  alias TreasureHunter.Wallet

  describe "fetch_or_create_mnemonic!/1" do
    test "creates a new mnemonic" do
      params = %{type: :bip39, mnemonic: "mnemonic"}

      mnemonic = Wallet.fetch_or_create_mnemonic!(params)

      assert params.type == mnemonic.type
      assert params.mnemonic == mnemonic.mnemonic
    end

    test "finds existing mnemonics" do
      mnemonic = insert(:mnemonic)

      found_mnemonic =
        Wallet.fetch_or_create_mnemonic!(%{type: mnemonic.type, mnemonic: mnemonic.mnemonic})

      assert mnemonic.id == found_mnemonic.id
    end
  end

  describe "create_address!/1" do
    test "creates new address" do
      mnemonic = insert(:mnemonic)
      path = "path"
      address = "address"

      params = %{
        mnemonic_id: mnemonic.id,
        path: path,
        address: address
      }

      created_address = Wallet.create_address!(params)

      assert path == created_address.path
      assert address == created_address.address
      assert mnemonic.id == created_address.mnemonic_id
      refute created_address.checked
    end
  end
end
