defmodule Varint.Mixfile do
  use Mix.Project

  def project do
    [
      app: :varint,
      version: "1.2.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      name: "Varint",
      source_url: "https://github.com/ahamez/varint",
      description: description(),
      package: package(),
    ]
  end

  def application do
    [applications: []]
  end


  defp deps do
    [
      {:dialyxir, "~> 0.5.1", only: :dev},
      {:ex_doc, "~> 0.19.0", only: :dev},
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
      links: %{"GitHub" => "https://github.com/ahamez/varint",}
    ]
  end

end
