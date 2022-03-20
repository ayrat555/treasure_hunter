defmodule TreasureHunter.Bitcoin.ExplorerAPI do
  alias TreasureHunter.HTTPClient

  @behaviour TreasureHunter.ExplorerAPI

  @base_url "https://blockstream.info/api/address/"

  @impl true
  def fetch_info(address) do
    address
    |> build_request()
    |> send_request()
  end

  defp build_request(address) do
    url = @base_url <> address

    Finch.build(:get, url)
  end

  defp send_request(request) do
    case Finch.request(request, HTTPClient) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        %{
          "chain_stats" => %{
            "tx_count" => tx_count,
            "funded_txo_sum" => funded_txo_sum,
            "spent_txo_sum" => spent_txo_sum
          }
        } = Jason.decode!(body)

        balance = (funded_txo_sum - spent_txo_sum) / 100_000_000

        result = %{tx_count: tx_count, balance: balance}

        {:ok, result}

      {:ok, %Finch.Response{body: body, status: status}} ->
        {:error, "Request failed #{inspect(status)}: #{inspect(body)}"}

      other ->
        other
    end
  end
end
