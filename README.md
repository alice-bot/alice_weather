# AliceWeather

This handler will allow Alice to provide the weather forecast of a given location.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `alice_weather` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:alice_weather, "~> 0.1.0"}
  ]
end
```

2. Add the handler to your list of registered handlers in `mix.exs`:

    ```elixir
    def application do
      [applications: [:alice],
        mod: {
          Alice, [Alice.Handlers.Weather, ...]}]
    end
    ```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/alice_weather](https://hexdocs.pm/alice_weather).


## Usage

Use `@alice help` for more information.
