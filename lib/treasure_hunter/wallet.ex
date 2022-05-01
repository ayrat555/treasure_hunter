defmodule TreasureHunter.Wallet do
  alias TreasureHunter.Repo
  alias TreasureHunter.Wallet.BitcoinAddress
  alias TreasureHunter.Wallet.DogecoinAddress
  alias TreasureHunter.Wallet.EthereumAddress
  alias TreasureHunter.Wallet.EthereumClassicAddress
  alias TreasureHunter.Wallet.GnosisAddress
  alias TreasureHunter.Wallet.Mnemonic
  alias TreasureHunter.Wallet.TronAddress
  alias TreasureHunter.Worker

  @addresses %{
    :bitcoin => BitcoinAddress,
    :dogecoin => DogecoinAddress,
    :tron => TronAddress,
    :gnosis => GnosisAddress,
    :ethereum => EthereumAddress,
    :ethereum_classic => EthereumClassicAddress
  }

  @spec fetch_or_create_mnemonic!(Map.t()) :: Mnemonic.t() | no_return()
  def fetch_or_create_mnemonic!(params) do
    case Repo.get_by(Mnemonic, params) do
      nil -> create_mnemonic!(params)
      found -> found
    end
  end

  @spec create_address!(Map.t(), atom()) :: Address.t() | no_return()
  def create_address!(params, chain \\ :bitcoin) do
    schema = address_schema(chain)

    case Repo.get_by(schema, params) do
      nil ->
        address = do_create_address!(schema, params)

        enqueue_job(address.id, chain)

        address

      found ->
        if !found.checked do
          enqueue_job(found.id, chain)
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

  @spec address_schema(atom()) :: module() | no_return()
  def address_schema(chain) do
    Map.fetch!(@addresses, chain)
  end

  @spec create_master_key(String.t()) :: Cryptopunk.Key.t()
  def create_master_key(mnemonic) do
    mnemonic
    |> Cryptopunk.create_seed()
    |> Cryptopunk.master_key_from_seed()
  end

  defp create_mnemonic!(params) do
    %Mnemonic{}
    |> Mnemonic.changeset(params)
    |> Repo.insert!()
  end

  defp do_create_address!(schema, params) do
    struct(schema)
    |> schema.changeset(params)
    |> Repo.insert!()
  end

  defp enqueue_job(id, chain) do
    %{id: id, chain: chain}
    |> Worker.new()
    |> Oban.insert()
  end
end
