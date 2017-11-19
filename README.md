# AliceWeather

This handler will allow Alice to provide the weather forecast of a given location.

## Installation

If [available in Hex](https://hex.pm/packages/alice_weather), the package can be installed as:

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

3. Set up the API keys and Geocodex `geocode_api_url` in your app's `config.exs`:
    ```elixir
	config :my_bot,
	  api_key: System.get_env("DARKSKY_API_KEY")

	config :geocodex,
	  api_key: System.get_env("GOOGLE_GEOCODING_API_KEY")

	config :geocodex,
	  geocode_api_url: "https://maps.googleapis.com/maps/api/geocode"
     ```
		   
## Usage

Use `@alice help` for more information.
