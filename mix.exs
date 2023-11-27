defmodule Gamora.MixProject do
  use Mix.Project

  @source_url "https://github.com/amco/gamora-ex"
  @version "0.9.0"

  def project do
    [
      app: :gamora,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Gamora.Application, []},
      extra_applications: [:logger, :oauth2, :ueberauth]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:oauth2, "~> 2.0"},
      {:cachex, "~> 3.6"},
      {:ueberauth, "~> 0.10"},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      formatters: ["html"],
      extras: ["CHANGELOG.md", "CONTRIBUTING.md", "README.md"]
    ]
  end

  defp package do
    [
      description: "An Uberauth strategy for Amco authentication.",
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE"],
      maintainers: ["Alejandro Gutiérrez"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url,
        Changelog: "https://hexdocs.pm/gamora/changelog.html"
      }
    ]
  end
end
