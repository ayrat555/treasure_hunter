defmodule TreasureHunter.Wallet do
  alias TreasureHunter.Repo
  alias TreasureHunter.Wallet.Address
  alias TreasureHunter.Wallet.Crypto
  alias TreasureHunter.Wallet.Mnemonic

  @spec fetch_or_create_mnemonic!(Map.t()) :: Mnemonic.t() | no_return()
  def fetch_or_create_mnemonic!(params) do
    case Repo.get_by(Mnemonic, params) do
      nil -> create_mnemonic!(params)
      found -> found
    end
  end

  @spec fetch_or_create_crypto!(atom()) :: Crypto.t() | no_return()
  def fetch_or_create_crypto!(type) do
    case Repo.get_by(Crypto, %{type: type}) do
      nil -> create_crypto!(type)
      found -> found
    end
  end

  @spec create_address!(Map.t()) :: Address.t() | no_return()
  def create_address!(params) do
    case Repo.get_by(Address, params) do
      nil ->
        create_addres!(params)

      found ->
        found
    end
  end

  @spec mnemonic_words() :: [String.t()]
  def mnemonic_words do
    :treasure_hunter
    |> :code.priv_dir()
    |> Path.join("words")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end

  defp create_mnemonic!(params) do
    %Mnemonic{}
    |> Mnemonic.changeset(params)
    |> Repo.insert!()
  end

  defp create_crypto!(type) do
    %Crypto{}
    |> Crypto.changeset(%{type: type})
    |> Repo.insert!()
  end

  defp create_addres!(params) do
    %Address{}
    |> Address.changeset(params)
    |> Repo.insert!()
  end
end
