defmodule TreasureHunter.Dogecoin.ExplorerAPI do
  alias TreasureHunter.HTTPClient

  require Logger

  @behaviour TreasureHunter.ExplorerAPI

  @base_url "https://sochain.com/api/v2/address/DOGE/"

  @impl true
  def fetch_info(address) do
    case do_fetch(address) do
      {:ok, result, _} -> {:ok, result}
      other -> other
    end
  end

  defp do_fetch(address) do
    Sage.new()
    |> Sage.run(:build_request, &build_request/2)
    |> Sage.run(:send_request, &send_request/2)
    |> Sage.run(:parse_body, &parse_body/2)
    |> Sage.run(:fetch_balance_and_txs, &fetch_balance_and_txs/2)
    |> Sage.execute(%{address: address})
  end

  defp build_request(_effects_so_far, %{address: address}) do
    url = @base_url <> address
    request = Finch.build(:get, url)

    {:ok, request}
  end

  defp send_request(%{build_request: request}, _params) do
    case Finch.request(request, HTTPClient) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Finch.Response{body: body, status: status}} ->
        {:error, "Request failed #{inspect(status)}: #{inspect(body)}"}

      other ->
        other
    end
  end

  defp parse_body(%{send_request: body}, _params) do
    Jason.decode(body)
  end

  defp fetch_balance_and_txs(%{parse_body: json}, %{address: address}) do
    case json do
      %{
        "code" => 200,
        "data" => %{
          "address" => ^address,
          "balance" => string_balance,
          "total_txs" => total_txs
        }
      } ->
        {balance, _} = Float.parse(string_balance)
        result = %{tx_count: total_txs, balance: balance}

        {:ok, result}

      other ->
        Logger.error("Dogecoin - invalid response #{inspect(other)}")
        {:error, :invalid_response}
    end
  end
end
