defmodule TreasureHunter.ExplorerAPI do
  @callback fetch_info(String.t()) :: {:ok, map()} | {:error, any()}
end
