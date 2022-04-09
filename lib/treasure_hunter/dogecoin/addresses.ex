defmodule TreasureHunter.Dogecoin.Addresses do
  alias Cryptopunk.Crypto.Dogecoin
  alias TreasureHunter.Wallet

  @legacy_path "m/44'/3'"
  @network :mainnet
  @accounts 1
  @changes 1
  @idxs 1

  @spec generate(String.t()) :: :ok
  def generate(mnemonic) do
    create_legacy_addresses(mnemonic)
    create_legacy_uncompressed_addresses(mnemonic)
  end

  defp create_legacy_addresses(mnemonic) do
    address_func = fn key ->
      Dogecoin.address(key, @network)
    end

    create_addresses(@legacy_path, mnemonic, address_func)
  end

  defp create_legacy_uncompressed_addresses(mnemonic) do
    address_func = fn key ->
      Dogecoin.address(key, @network, uncompressed: true)
    end

    create_addresses(@legacy_path, mnemonic, address_func, %{uncompressed: true})
  end

  defp create_addresses(path_prefix, mnemonic, address_func, additional_params \\ %{}) do
    master_key = Wallet.create_master_key(mnemonic.mnemonic)
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

      Wallet.create_address!(params, :dogecoin)
    end)
  end

  defp create_raw_paths(path_prefix) do
    Enum.flat_map(0..@accounts, fn account ->
      Enum.flat_map(0..@idxs, fn idx ->
        Enum.map(0..@changes, fn change ->
          path_prefix <> "/#{account}'/#{change}/#{idx}"
        end)
      end)
    end)
  end
end
