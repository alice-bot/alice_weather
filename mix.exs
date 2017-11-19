defmodule AliceWeather.Mixfile do
  use Mix.Project

  def project do
    [
      app: :alice_weather,
      version: "0.2.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: "A handler for the Alice Slack bot. Allows Alice to provide the weather forecast of a given location.",
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [

      {:geocodex, "~> 0.1.0"},
      {:json, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:alice, "~> 0.3"}
    ]
  end

  defp package do
    [files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Mohammed Khalid"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mushfick/alice_weather"}]
  end
end
