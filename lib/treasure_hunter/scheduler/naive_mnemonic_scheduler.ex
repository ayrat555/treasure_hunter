defmodule TreasureHunter.NaiveMnemonicScheduler do
  alias TreasureHunter.Bitcoin.Addresses, as: BitcoinAddresses
  alias TreasureHunter.Dogecoin.Addresses, as: DogecoinAddresses
  alias TreasureHunter.Ethereum.Addresses, as: EthereumAddresses
  alias TreasureHunter.EthereumClassic.Addresses, as: EthereumClassicAddresses
  alias TreasureHunter.Gnosis.Addresses, as: GnosisAddresses
  alias TreasureHunter.Tron.Addresses, as: TronAddresses
  alias TreasureHunter.Wallet

  @mnemonic_lengths [12, 15, 18, 21, 24]
  @seed_type :bip39

  def create_addresses_from_naive_mnemonics(chain, first_run \\ true) do
    mnemonics = create_mnemonics(first_run)

    Enum.each(mnemonics, fn mnemonic ->
      if !mnemonic.checked do
        create_addresses(chain, mnemonic)

        Wallet.update_mnemonic!(mnemonic, %{checked: true})
      end
    end)
  end

  defp create_mnemonics(first_run) do
    words = Wallet.mnemonic_words()

    Enum.flat_map(words, fn word ->
      Enum.map(@mnemonic_lengths, fn length ->
        create_mnemonic(word, length, first_run)
      end)
    end)
  end

  defp create_addresses(:bitcoin, mnemonic) do
    BitcoinAddresses.generate(mnemonic)
  end

  defp create_addresses(:dogecoin, mnemonic) do
    DogecoinAddresses.generate(mnemonic)
  end

  defp create_addresses(:tron, mnemonic) do
    TronAddresses.generate(mnemonic)
  end

  defp create_addresses(:gnosis, mnemonic) do
    GnosisAddresses.generate(mnemonic)
  end

  defp create_addresses(:ethereum, mnemonic) do
    EthereumAddresses.generate(mnemonic)
  end

  defp create_addresses(:ethereum_classic, mnemonic) do
    EthereumClassicAddresses.generate(mnemonic)
  end

  defp create_mnemonic(word, length, first_run) do
    mnemonic =
      word
      |> List.duplicate(length)
      |> Enum.join(" ")

    params = %{mnemonic: mnemonic, type: @seed_type}
    mnemonic = Wallet.fetch_or_create_mnemonic!(params)

    if first_run do
      Wallet.update_mnemonic!(mnemonic, %{checked: false})
    else
      mnemonic
    end
  end
end
