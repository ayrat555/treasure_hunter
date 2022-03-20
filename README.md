# TreasureHunter

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `treasure_hunter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:treasure_hunter, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/treasure_hunter>.

## Queries

### Found mnemonics

```sql
SELECT DISTINCT mnemonic, addresses.path FROM mnemonics
INNER JOIN addresses ON mnemonics.id = addresses.mnemonic_id
where addresses.tx_count > 0;
```

### Checking bigger ranges


```elixir
alias Cryptopunk.Crypto.Bitcoin
bech32_path = "m/84'/0'"

mnemonic = "word word word word word word word word word word word word"


Enum.map(0..20, fn idx ->
  {:ok, path} = Cryptopunk.parse_path(bech32_path <> "/0'/0/#{idx}");

    master_key = mnemonic
    |> Cryptopunk.create_seed()
    |> Cryptopunk.master_key_from_seed()

    key = Cryptopunk.derive_key(master_key, path)
    Bitcoin.bech32_address(key, :mainnet) |> IO.inspect() |>  TreasureHunter.Bitcoin.ExplorerAPI.fetch_info() |> IO.inspect
end)
```
