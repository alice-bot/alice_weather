defmodule AliceWeatherTest do
  use ExUnit.Case
  doctest AliceWeather

  test "greets the world" do
    assert AliceWeather.hello() == :world
  end
end
