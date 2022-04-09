defmodule TreasureHunter.Factory do
  use ExMachina.Ecto, repo: TreasureHunter.Repo

  alias TreasureHunter.Wallet.BitcoinAddress
  alias TreasureHunter.Wallet.Mnemonic

  def bitcoin_address_factory do
    %BitcoinAddress{
      path: "path",
      mnemonic: build(:mnemonic),
      address: "address"
    }
  end

  def mnemonic_factory do
    %Mnemonic{
      type: :bip39,
      mnemonic: "secret"
    }
  end
end
