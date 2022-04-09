defmodule TreasureHunter.WorkerTest do
  use TreasureHunter.DataCase

  import Mox

  setup :verify_on_exit!

  alias TreasureHunter.Worker

  describe "perfom/1" do
    test "fetches tx_count, balance and updates address" do
      address = insert(:bitcoin_address)
      response = %{tx_count: 100, balance: 1}

      MockExplorerAPI
      |> expect(:fetch_info, fn _ -> {:ok, response} end)

      assert {:ok, updated_address} =
               Worker.perform(%{args: %{"id" => address.id, "chain" => "bitcoin"}})

      assert updated_address.checked
      assert response.tx_count == updated_address.tx_count
      assert Decimal.new(response.balance) == updated_address.balance
    end
  end
end
