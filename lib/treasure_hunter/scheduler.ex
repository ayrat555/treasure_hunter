defmodule TreasureHunter.Scheduler do
  import Ecto.Query

  alias Cryptopunk.Crypto.Bitcoin
  alias TreasureHunter.Repo
  alias TreasureHunter.Wallet
  alias TreasureHunter.Wallet.BitcoinAddress
  alias TreasureHunter.Wallet.Mnemonic
  alias TreasureHunter.Worker

  @legacy_path "m/44'/0'"
  @bech32_path "m/84'/0'"
  @p2sh_p2wpkh_path "m/49'/0'"
  @mnemonic_lengths [12, 15, 18, 21, 24]
  @network :mainnet
  @seed_type :bip39

  def create_addresses_from_naive_mnemonics do
    mnemonics = create_mnemonics()

    Enum.each(mnemonics, fn mnemonic ->
      if !mnemonic.checked do
        create_legacy_addresses(mnemonic)
        create_legacy_uncompressed_addresses(mnemonic)
        create_bech32_addresses(mnemonic)
        create_p2sh_p2wpkh_addresses(mnemonic)

        Wallet.update_mnemonic!(mnemonic, %{checked: true})
      end
    end)
  end

  def create_addresses_changing_first_word do
    mnemonics =
      Mnemonic
      |> where(
        [m],
        is_nil(m.checked) or m.checked == false
      )
      |> limit(100)
      |> Repo.all(timeout: 100_000)

    Enum.each(mnemonics, fn mnemonic ->
      if !mnemonic.checked do
        create_legacy_addresses(mnemonic)
        create_legacy_uncompressed_addresses(mnemonic)
        create_bech32_addresses(mnemonic)
        create_p2sh_p2wpkh_addresses(mnemonic)

        Wallet.update_mnemonic!(mnemonic, %{checked: true})
      end
    end)

    if Enum.empty?(mnemonics) do
      :ok
    else
      create_addresses_changing_first_word()
    end
  end

  def enqueue_addresses_for_processing do
    addresses =
      BitcoinAddress
      |> where(
        [address],
        address.checked == false or is_nil(address.checked)
      )
      |> limit(500)
      |> Repo.all()

    if Enum.empty?(addresses) do
      :ok
    else
      for address <- addresses do
        %{id: address.id}
        |> Worker.new()
        |> Oban.insert()
      end

      enqueue_addresses_for_processing()
    end
  end

  defp create_legacy_addresses(mnemonic) do
    address_func = fn key ->
      Bitcoin.legacy_address(key, @network)
    end

    create_addresses(@legacy_path, mnemonic, address_func)
  end

  defp create_legacy_uncompressed_addresses(mnemonic) do
    address_func = fn key ->
      Bitcoin.legacy_address(key, @network, uncompressed: true)
    end

    create_addresses(@legacy_path, mnemonic, address_func, %{uncompressed: true})
  end

  defp create_bech32_addresses(mnemonic) do
    address_func = fn key ->
      Bitcoin.bech32_address(key, @network)
    end

    create_addresses(@bech32_path, mnemonic, address_func)
  end

  defp create_p2sh_p2wpkh_addresses(mnemonic) do
    address_func = fn key ->
      Bitcoin.p2sh_p2wpkh_address(key, @network)
    end

    create_addresses(@p2sh_p2wpkh_path, mnemonic, address_func)
  end

  def create_mnemonics do
    words = Wallet.mnemonic_words()

    Enum.flat_map(words, fn word ->
      Enum.map(@mnemonic_lengths, fn length ->
        mnemonic =
          word
          |> List.duplicate(length)
          |> Enum.join(" ")

        params = %{mnemonic: mnemonic, type: @seed_type}
        Wallet.fetch_or_create_mnemonic!(params)
      end)
    end)
  end

  def create_first_word_mnemonics do
    words = Wallet.mnemonic_words()

    words
    |> Enum.chunk_every(1200)
    |> List.last()
    |> Enum.each(fn word ->
      Enum.each(@mnemonic_lengths, fn length ->
        Enum.each(words, fn first_word ->
          if first_word != word do
            base = List.duplicate(word, length - 1)

            mnemonic = Enum.join([first_word | base], " ")

            params = %{mnemonic: mnemonic, type: @seed_type}
            Wallet.fetch_or_create_mnemonic!(params)
          end
        end)

        # |> Enum.reject(&is_nil/1)
      end)
    end)
  end

  defp create_addresses(path_prefix, mnemonic, address_func, additional_params \\ %{}) do
    master_key = create_master_key(mnemonic.mnemonic)
    raw_paths = create_raw_paths(path_prefix)

    Enum.each(raw_paths, fn raw_path ->
      {:ok, path} = Cryptopunk.parse_path(raw_path)
      derived_key = Cryptopunk.derive_key(master_key, path)

      address = address_func.(derived_key)

      params =
        Map.merge(
          %{address: address, path: raw_path, mnemonic_id: mnemonic.id},
          additional_params
        )

      Wallet.create_address!(params)
    end)
  end

  defp create_master_key(mnemonic) do
    mnemonic
    |> Cryptopunk.create_seed()
    |> Cryptopunk.master_key_from_seed()
  end

  defp create_raw_paths(path_prefix) do
    accounts = 1
    changes = 0
    idxs = 1

    Enum.flat_map(0..accounts, fn account ->
      Enum.flat_map(0..idxs, fn idx ->
        Enum.map(0..changes, fn change ->
          path_prefix <> "/#{account}'/#{change}/#{idx}"
        end)
      end)
    end)
  end
end
