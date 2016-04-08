defmodule Pragmatic.Mixfile do
  use Mix.Project

  def project do
    [app: :pragmatic,
     version: "0.1.7",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:earmark, "~> 0.2.1", only: :dev},
      {:ex_doc, "~> 0.11.4", only: :dev}
    ]
  end

  defp description do
    """
    A small, simple library to deal with the practical issues arising from using Elixir on Windows
    """
  end

  defp package do
    [
    maintainers: ["Onorio Catenacci"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/OnorioCatenacci/pragmatic"}
    ]
  end
end
