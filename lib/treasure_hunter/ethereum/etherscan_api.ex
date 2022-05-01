defmodule TreasureHunter.Ethereum.EtherscanAPI do
  alias TreasureHunter.HTTPClient

  require Logger

  @behaviour TreasureHunter.ExplorerAPI

  @base_url "https://api.etherscan.io/api"
  @balance_params %{module: "account", action: "balance", tag: "latest"}
  @tx_params %{
    module: "account",
    action: "txlist",
    startblock: 0,
    endblock: 14_686_160,
    page: 1,
    offset: 10,
    sort: "asc"
  }

  @impl true
  def fetch_info(address) do
    with {:ok, balance, _} <- fetch_balance(address),
         {:ok, txs, _} <- fetch_txs(address) do
      if balance > 0 or !Enum.empty?(txs) do
        {:ok, %{balance: %{balance: balance, txs: true}, tx_count: Enum.count(txs)}}
      else
        {:ok, %{balance: nil, tx_count: nil}}
      end
    end
  end

  defp fetch_txs(address) do
    Sage.new()
    |> Sage.run(:build_request, &build_request/2)
    |> Sage.run(:maybe_wait_rate_limit, &maybe_wait_rate_limit/2)
    |> Sage.run(:send_request, &send_request/2)
    |> Sage.run(:parse_body, &parse_body/2)
    |> Sage.run(:parse_txs, &parse_txs/2)
    |> Sage.execute(%{address: address, request: :txs})
  end

  defp fetch_balance(address) do
    Sage.new()
    |> Sage.run(:build_request, &build_request/2)
    |> Sage.run(:maybe_wait_rate_limit, &maybe_wait_rate_limit/2)
    |> Sage.run(:send_request, &send_request/2)
    |> Sage.run(:parse_body, &parse_body/2)
    |> Sage.run(:parse_balance, &parse_balance/2)
    |> Sage.execute(%{address: address, request: :balance})
  end

  defp build_request(_effects_so_far, %{address: address, request: :balance}) do
    encoded_params =
      %{address: address, apikey: api_key()}
      |> Map.merge(@balance_params)
      |> URI.encode_query()

    url = @base_url <> "?" <> encoded_params
    request = Finch.build(:get, url)

    {:ok, request}
  end

  defp build_request(_effects_so_far, %{address: address, request: :txs}) do
    encoded_params =
      %{address: address, apikey: api_key()}
      |> Map.merge(@tx_params)
      |> URI.encode_query()

    url = @base_url <> "?" <> encoded_params
    request = Finch.build(:get, url)

    {:ok, request}
  end

  defp maybe_wait_rate_limit(_effects_so_far, _params) do
    maybe_wait()
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

  defp parse_balance(
         %{parse_body: %{"message" => "OK", "result" => balance, "status" => "1"}},
         _
       ) do
    {:ok, String.to_integer(balance)}
  end

  defp parse_balance(%{parse_body: parse_body}, _) do
    Logger.error("Failed to parse balance #{inspect(parse_body)}")

    {:error, :response_error}
  end

  defp parse_txs(
         %{parse_body: %{"message" => "No transactions found", "result" => [], "status" => "0"}},
         _
       ) do
    {:ok, []}
  end

  defp parse_txs(
         %{
           parse_body: %{
             "message" => "OK",
             "result" => txs,
             "status" => "1"
           }
         },
         _
       ) do
    {:ok, txs}
  end

  defp parse_txs(%{parse_body: parse_body}, _) do
    Logger.error("Failed to parse txs #{inspect(parse_body)}")

    {:error, :response_error}
  end

  defp api_key do
    :treasure_hunter
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:api_key)
  end

  defp maybe_wait do
    case ExRated.check_rate("etherscan", 1_000, 3) do
      {:ok, _} = result ->
        result

      _other ->
        Process.sleep(1_000)
        maybe_wait()
    end
  end
end
