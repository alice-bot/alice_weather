defmodule Alice.Handlers.Weather do
  @moduledoc "Lets users get weather information for a given location"

  use Alice.Router
  alias Alice.Weather.Location

  @default_minutely_summary %{"minutely" => %{"summary" => ""}}

  command ~r/weather ((for|in) )?(?<location>.+)/i, :weather
  route   ~r/^weather ((for|in) )?(?<location>.+)/i, :weather

  @doc """
  `weather <location>`
  `weather in <location>`
  `weather for <location>`
  Get weather forecast for the given location.
  Location can be an address, a city or a zip code.
  """
  def weather(conn) do
    weather_summary = with term <- Alice.Conn.last_capture(conn),
         {:ok, %Location{} = loc} <- reverse_geocode(term),
         url <- darksky_url(loc),
         {:ok, response} <- HTTPoison.get(url),
         {:ok, weather_data} <- parse_forecast(response)
    do
      delayed_reply(conn, ~s(Please visit darksky.net/forecast/#{loc.lat},#{loc.lng}/us12/en for detailed forecast.), 200)
      summarize(weather_data, loc)
    else
      {:error, :cannot_parse_location} ->
        "Sorry, I can't find that location"
      {:error, :http_error, %HTTPoison.Response{status_code: code}} ->
        "HTTP error: #{code}"
      _any_other_error ->
        "Unknown error :("
    end

    reply(conn, weather_summary)
  end

  defp reverse_geocode(location) do
    location
    |> Geocodex.address
    |> parse_geocoder_response
  end

  defp parse_geocoder_response(response) do
    with %{"results" => [results]} <- response,
         %{"address_components" => components} <- results,
         %{"geometry" => %{"location" => %{"lat" => lat, "lng" => lng}}} <- results
    do
      name = Enum.find(components, fn(component)->
        "locality" in component["types"]
      end)["long_name"]
      {:ok, Location.new(name, {lat, lng})}
    else
      _ -> {:error, :cannot_parse_location}
    end
  end

  defp darksky_url(%Location{lat: lat, lng: lng}), do: "https://api.darksky.net/forecast/#{api_key()}/#{lat},#{lng}"

  defp parse_forecast(%HTTPoison.Response{body: body, status_code: 200}), do: {:ok, JSON.decode!(body)}
  defp parse_forecast(response), do: {:error, :http_error, response}

  defp summarize(weather_data, %Location{name: location_name}) do
    %{
      "currently" => %{"apparentTemperature" => temperature},
      "daily" => %{"summary" => daily_summary},
      "hourly" => %{"summary" => hourly_summary},
      "minutely" => %{"summary" => minutely_summary}
    } = merge_defaults(weather_data)

    ~s(Current temperature in #{location_name}: *#{round(temperature)}°F*\nSummary: #{daily_summary} #{hourly_summary} #{minutely_summary})
  end

  defp merge_defaults(map), do: Map.merge(@default_minutely_summary, map)

  defp api_key do
    Application.get_env(:alice_weather, :api_key)
  end
end
