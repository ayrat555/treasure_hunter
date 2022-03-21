defmodule TreasureHunter.Wallet do
  alias TreasureHunter.Bitcoin.Worker
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
        address = do_create_address!(params)

        enqueue_job(address.id)

        address

      found ->
        if !found.checked do
          enqueue_job(found.id)
        end

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

  @spec update_mnemonic!(Mnemonic.t(), Map.t()) :: Mnemonic.t() | no_return()
  def update_mnemonic!(mnemonic, params) do
    mnemonic
    |> Mnemonic.changeset(params)
    |> Repo.update!()
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

  defp do_create_address!(params) do
    %Address{}
    |> Address.changeset(params)
    |> Repo.insert!()
  end

  defp enqueue_job(id) do
    %{id: id}
    |> Worker.new()
    |> Oban.insert()
  end
end
