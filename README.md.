# TreasureHunter

A project for hacking crypto wallets protected with naive mnemonics.

See https://www.badykov.com/common/hack/

## Description

For each blockchain, it does the following:

1. Generates 10_240 master keys from naive mnemonics
2. Derives a fixed number of private keys from the master keys
3. For each generated child key, it generates some addresses according to [BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) and [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
4. Each generated address is checked against a block explorer. Since block explorer APIs are not consistent across all blockchains, the project implements API wrappers for each of them
5. If the address is found in a block explorer, it means we succeeded and found a mnemonic that can unlock it

For steps 1 - 3 my crypto wallet library ["Cryptopunk"](https://github.com/ayrat555/cryptopunk) is used, it contains the required logic for generating different types of addresses from public keys.

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


### Chain backlog

  * Bitcoin Gold
  * Ethereum
  * Binance Smart Chain
  * Tron
