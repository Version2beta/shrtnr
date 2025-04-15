defmodule Shrtnr.Application do
  use Application

  def start(_type, _args) do
    children = [
      Shrtnr.Repo,
      {Bandit,
       plug: Shrtnr.Router, scheme: :http, port: Application.get_env(:shrtnr, :port, 8080)}
    ]

    opts = [strategy: :one_for_one, name: Shrtnr.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
