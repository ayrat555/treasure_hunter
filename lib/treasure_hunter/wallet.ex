defmodule TreasureHunter.Wallet do
  alias TreasureHunter.Repo
  alias TreasureHunter.Wallet.Mnemonic

  @spec fetch_or_create(Keyword.t()) :: Mnemonic.t()
  def fetch_or_create(params) do
    case Repo.get_by(Mnemonic, params) do
      nil -> create_mnemonic!(params)
      found -> found
    end
  end

  defp create_mnemonic!(params) do
    %Mnemonic{}
    |> Mnemonic.changeset(params)
    |> Repo.insert!()
  end
end
