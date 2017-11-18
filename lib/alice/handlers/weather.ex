defmodule Alice.Handlers.Weather do
  @moduledoc "Lets users get weather information for a given location"

  use Alice.Router
  alias Alice.Conn

  @api_key Application.get_env(:alice_weather, :api_key)
  
  command ~r/weather (?<term>.+)/i, :forecast
  route ~r/^weather (?<term>.+)/i, :forecast

  @doc """
  `<location>` - Get weather forecast for the given location.
  Location can an address, a city or a zip code.
  """
  def forecast(%Conn{message: %{captures: captures}}=conn) do
    location = captures
    location
    |> reverse_geocode
    |> temperature_url
    |> get_forecast
    |> parse_response
    |> summarize(location, conn)
  end

  def reverse_geocode(location) do
    location
    |> Geocoder.call
    |> parse_geocoder_response
  end

  def parse_geocoder_response({:ok, %Geocoder.Coords{lat: lat, lon: lon}}), do: {lat, lon}
  def parse_geocoder_response({:error, _}), do: :error

  def temperature_url({lat, lon}), do: {:ok, "https://api.darksky.net/forecast/#{@api_key}/#{lat},#{lon}"}
  def temperature_url(_), do: :error

  def get_forecast({:ok, location_url}), do: HTTPoison.get(location_url)
  def get_forecast(_), do: :error

  def parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}), do: {:ok, JSON.decode!(body)}
  def parse_response(_), do: :error

  def summarize({:ok, json}, location, conn) do
    %{
      "currently" => %{"apparentTemperature" => temperature}, 
      "daily" => %{"summary" => daily_summary},
      "hourly" => %{"summary" => hourly_summary},
      "minutely" => %{"summary" => minutely_summary}
    } = json

    reply(conn, ~s(Current temperature for #{location}: #{temperature}F\nSummary: #{daily_summary} #{hourly_summary} #{minutely_summary}))
  end
end

