defmodule TreasureHunter.Factory do
  use ExMachina.Ecto, repo: TreasureHunter.Repo

  alias TreasureHunter.Wallet.Crypto
  alias TreasureHunter.Wallet.Mnemonic

  def mnemonic_factory do
    %Mnemonic{
      type: :bip39,
      mnemonic: "secret"
    }
  end

  def crypto_factory do
    %Crypto{
      type: :bitcoin
    }
  end
end
