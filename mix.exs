defmodule Shrtnr.MixProject do
  use Mix.Project

  def project do
    [
      app: :shrtnr,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        files: ~w(lib priv mix.exs README.md)
      ],
      releases: [
        shrtnr: [
          include_executables_for: [:unix],
          applications: [shrtnr: :permanent],
          files: ["priv/**/*"]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Shrtnr.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.17"},
      {:bandit, "~> 1.6"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},
      {:csv, "~> 3.2"},
      {:httpoison, "~> 2.1", only: [:dev, :test, :benchmark]}
    ]
  end
end
