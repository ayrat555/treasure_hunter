defmodule TreasureHunter.Dogecoin.ExplorerAPI do
  alias TreasureHunter.HTTPClient

  @behaviour TreasureHunter.ExplorerAPI

  @base_url "https://sochain.com/api/v2/address/DOGE/"

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
        case Jason.decode(body) do
          %{
            "status" => "success",
            "data" => %{
              "balance" => balance,
              "total_txs" => tx_count
            }
          } ->
            result = %{tx_count: tx_count, balance: balance}

            {:ok, result}

          other ->
            {:error, "Request failed : #{inspect(other)}"}
        end

      {:ok, %Finch.Response{body: body, status: status}} ->
        {:error, "Request failed #{inspect(status)}: #{inspect(body)}"}

      other ->
        other
    end
  end
end
