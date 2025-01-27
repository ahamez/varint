defmodule Varint.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ahamez/varint"

  def project do
    [
      app: :varint,
      version: "1.5.1",
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Varint",
      source_url: @source_url,
      docs: [main: "readme", extras: ["README.md"]],
      description: description(),
      dialyzer: [plt_local_path: "priv/plts"],
      package: package(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:castore, "~> 1.0", only: :test, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: [:test], runtime: false},
      {:stream_data, "~> 1.0", only: [:dev, :test], runtime: false}
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
