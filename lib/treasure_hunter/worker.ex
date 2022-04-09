defmodule TreasureHunter.Worker do
  use Oban.Worker,
    unique: [period: 30]

  alias TreasureHunter.Repo
  alias TreasureHunter.Wallet
  alias TreasureHunter.Wallet.BitcoinAddress

  @impl Worker
  def perform(%{args: %{"id" => address_id, "chain" => chain}}) do
    case do_perform(address_id, chain) do
      {:ok, address, _} -> {:ok, address}
      error -> error
    end
  end

  defp do_perform(address_id, chain) do
    Sage.new()
    |> Sage.run(:fetch_schema, &fetch_schema/2)
    |> Sage.run(:fetch_address, &fetch_address/2)
    |> Sage.run(:fetch_tx_count_and_balance, &fetch_tx_count_and_balance/2)
    |> Sage.run(:update_address, &update_address/2)
    |> Sage.execute(%{address_id: address_id, chain: chain})
  end

  defp fetch_schema(_effects_so_far, %{chain: chain}) do
    schema =
      chain
      |> String.to_existing_atom()
      |> Wallet.address_schema()

    {:ok, schema}
  end

  defp fetch_address(_effects_so_far, %{address_id: id}) do
    case Repo.get_by(BitcoinAddress, id: id) do
      nil -> {:error, :not_found}
      address -> {:ok, address}
    end
  end

  defp fetch_tx_count_and_balance(%{fetch_address: address}, _params) do
    api_client().fetch_info(address.address)
  end

  defp update_address(
         %{
           fetch_address: address,
           fetch_tx_count_and_balance: %{tx_count: tx_count, balance: balance}
         },
         _params
       ) do
    address
    |> BitcoinAddress.changeset(%{tx_count: tx_count, balance: balance, checked: true})
    |> Repo.update()
  end

  defp api_client do
    :treasure_hunter
    |> Application.fetch_env!(Bitcoin)
    |> Keyword.fetch!(:api_client)
  end
end
