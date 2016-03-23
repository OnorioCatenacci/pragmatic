defmodule Pragmatic.Mixfile do
  use Mix.Project

  def project do
    [app: :pragmatic,
     version: "0.1.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.11.4"},
      {:earmark, "~> 0.2.1"}
    ]
  end

  defp description do
    """
    A small, simple library to deal with the practical issue of paths with spaces on Windows
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
