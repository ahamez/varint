defmodule Varint.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ahamez/varint"

  def project do
    [
      app: :varint,
      version: "1.3.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Varint",
      source_url: @source_url,
      docs: [main: "readme", extras: ["README.md"]],
      description: description(),
      dialyzer: [plt_file: {:no_warn, "priv/plts/dialyzer.plt"}],
      package: package(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:castore, "~> 1.0"},
      {:credo, "~> 1.5", only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: [:test], runtime: false},
      {:git_hooks, "~> 0.5", only: [:test, :dev], runtime: false}
    ]
  end

  defp description do
    """
    A library to compress integers using LEB128.
    """
  end

  defp package do
    [
      name: :varint,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Alexandre Hamez"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
