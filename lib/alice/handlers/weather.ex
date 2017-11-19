defmodule Alice.Handlers.Weather do
  @moduledoc "Lets users get weather information for a given location"

  use Alice.Router
  alias Alice.Conn

  @api_key Application.get_env(:alice_weather, :api_key)
  @default_minutely_summary %{"minutely" => %{"summary" => ""}}
  
  command ~r/weather (?<term>.+)/i, :weather
  route ~r/^weather for (?<term>.+)/i, :weather

  @doc """
  `<location>` - Get weather forecast for the given location.
  Location can an address, a city or a zip code.
  """
  def weather(%Conn{message: %{captures: captures}}=conn) do
    [_term, location] = captures

    location
    |> reverse_geocode
    |> temperature_url
    |> get_forecast
    |> parse_response
    |> summarize(location, conn)
  end

  defp reverse_geocode(location) do
    location
    |> Geocodex.address
    |> parse_geocoder_response
  end


  defp parse_geocoder_response(%{"results" => [%{"geometry" => %{"location" => %{"lat" => lat, "lng" => lon}}}]}), do: {lat, lon}
  defp parse_geocoder_response(_), do: :error

  defp temperature_url({lat, lon}), do: {:ok, "https://api.darksky.net/forecast/#{@api_key}/#{lat},#{lon}"}
  defp temperature_url(_), do: :error

  defp get_forecast({:ok, location_url}), do: HTTPoison.get(location_url)
  defp get_forecast(_), do: :error

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}), do: {:ok, JSON.decode!(body)}
  defp parse_response(_), do: :error

  defp summarize({:ok, weather_data}, location, conn) do
    %{
      "currently" => %{"apparentTemperature" => temperature}, 
      "daily" => %{"summary" => daily_summary},
      "hourly" => %{"summary" => hourly_summary},
      "minutely" => %{"summary" => minutely_summary}
    } = merge_defaults(weather_data)

    reply(conn, ~s(Current temperature for #{location}: *#{temperature}F*\nSummary: #{daily_summary} #{hourly_summary} #{minutely_summary}))
  end
  defp summarize(:error, _location, conn), do: reply(conn, ~s(Whoops, that didn't work.))

  defp merge_defaults(map), do: Map.merge(@default_minutely_summary, map)
end
