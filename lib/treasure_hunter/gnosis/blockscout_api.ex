defmodule TreasureHunter.Gnosis.BlockscoutAPI do
  alias TreasureHunter.HTTPClient

  require Logger

  @behaviour TreasureHunter.ExplorerAPI

  @base_url "https://blockscout.com/xdai/mainnet/api"
  @balance_path "?module=account&action=balance&address="
  @tokens_path "?module=account&action=tokenlist&address="

  @impl true
  def fetch_info(address) do
    with {:ok, balance, _} <- fetch_balance(address),
         {:ok, tokens, _} <- fetch_token_balances(address) do
      if balance > 0 or !Enum.empty?(tokens) do
        {:ok, %{balance: %{balance: balance, tokens: tokens}, tx_count: nil}}
      else
        {:ok, %{balance: nil, tx_count: nil}}
      end
    end
  end

  defp fetch_token_balances(address) do
    Sage.new()
    |> Sage.run(:build_request, &build_request/2)
    |> Sage.run(:maybe_wait_rate_limit, &maybe_wait_rate_limit/2)
    |> Sage.run(:send_request, &send_request/2)
    |> Sage.run(:parse_body, &parse_body/2)
    |> Sage.run(:parse_tokens, &parse_tokens/2)
    |> Sage.execute(%{address: address, request: :tokens})
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
    url = @base_url <> @balance_path <> address
    request = Finch.build(:get, url)

    {:ok, request}
  end

  defp build_request(_effects_so_far, %{address: address, request: :tokens}) do
    url = @base_url <> @tokens_path <> address
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

  defp parse_tokens(
         %{parse_body: %{"message" => "No tokens found", "result" => [], "status" => "0"}},
         _
       ) do
    {:ok, []}
  end

  defp parse_tokens(
         %{
           parse_body: %{
             "message" => "OK",
             "result" => tokens,
             "status" => "1"
           }
         },
         _
       ) do
    {:ok, tokens}
  end

  defp parse_tokens(%{parse_body: parse_body}, _) do
    Logger.error("Failed to parse balance #{inspect(parse_body)}")

    {:error, :response_error}
  end

  defp maybe_wait do
    case ExRated.check_rate("blockscout", 2_000, 1) do
      {:ok, _} = result ->
        result

      _other ->
        Process.sleep(1_000)
        maybe_wait()
    end
  end
end
