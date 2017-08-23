defmodule Pragmatic.Mixfile do
  use Mix.Project

  def project do
    [app: :pragmatic,
     version: "0.1.8",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     compilers: [:rustler] ++ Mix.compilers(),
     rustler_crates: rustler_crates(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:earmark,"~> 1.2", only: :dev},
      {:ex_doc, "~> 0.16.2", only: :dev},
      {:rustler, "~> 0.10.1"}
    ]
  end

  defp description do
    """
    A small, simple library to deal with the practical issues arising from using Elixir on Windows
    """
  end

  defp rustler_crates do
    [Pragmatic: [
        path: "native/pragmatic",
        mode: (if Mix.env == :prod, do: :release, else: :debug),
      ]]
  end

  defp package do
    [
    maintainers: ["Onorio Catenacci"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/OnorioCatenacci/pragmatic"}
    ]
  end
end
