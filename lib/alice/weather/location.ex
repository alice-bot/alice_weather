defmodule Alice.Weather.Location do
  @moduledoc "Location struct for Alice Weather"

  @type name      :: binary
  @type latitude  :: float
  @type longitude :: float

  @type t :: %__MODULE__{
    name: name,
    lat:  latitude,
    lng:  longitude
  }

  defstruct name: nil,
            lat: lat,
            lng: lng

  def new(name, {lat, lng}) do
    %__MODULE__{name: name, lat: lat, lng: lng}
  end
end
