defmodule TreasureHunter.BlockscoutAPI do
  alias TreasureHunter.HTTPClient

  require Logger

  @balance_path "?module=account&action=balance&address="
  @tokens_path "?module=account&action=tokenlist&address="

  def fetch_info(address, base_url) do
    with {:ok, balance, _} <- fetch_balance(address, base_url),
         {:ok, tokens, _} <- fetch_token_balances(address, base_url) do
      if balance > 0 or !Enum.empty?(tokens) do
        {:ok, %{balance: %{balance: balance, tokens: tokens}, tx_count: nil}}
      else
        {:ok, %{balance: nil, tx_count: nil}}
      end
    end
  end

  defp fetch_token_balances(address, base_url) do
    Sage.new()
    |> Sage.run(:build_request, &build_request/2)
    |> Sage.run(:maybe_wait_rate_limit, &maybe_wait_rate_limit/2)
    |> Sage.run(:send_request, &send_request/2)
    |> Sage.run(:parse_body, &parse_body/2)
    |> Sage.run(:parse_tokens, &parse_tokens/2)
    |> Sage.execute(%{address: address, base_url: base_url, request: :tokens})
  end

  defp fetch_balance(address, base_url) do
    Sage.new()
    |> Sage.run(:build_request, &build_request/2)
    |> Sage.run(:maybe_wait_rate_limit, &maybe_wait_rate_limit/2)
    |> Sage.run(:send_request, &send_request/2)
    |> Sage.run(:parse_body, &parse_body/2)
    |> Sage.run(:parse_balance, &parse_balance/2)
    |> Sage.execute(%{address: address, base_url: base_url, request: :balance})
  end

  defp build_request(_effects_so_far, %{address: address, base_url: base_url, request: :balance}) do
    url = base_url <> @balance_path <> address
    request = Finch.build(:get, url)

    {:ok, request}
  end

  defp build_request(_effects_so_far, %{address: address, base_url: base_url, request: :tokens}) do
    url = base_url <> @tokens_path <> address
    request = Finch.build(:get, url)

    {:ok, request}
  end

  defp maybe_wait_rate_limit(_effects_so_far, %{base_url: base_url}) do
    maybe_wait(base_url)
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

  defp maybe_wait(base_url) do
    case ExRated.check_rate("blockscout" <> "-" <> base_url, 2_000, 1) do
      {:ok, _} = result ->
        result

      _other ->
        Process.sleep(1_000)
        maybe_wait(base_url)
    end
  end
end
