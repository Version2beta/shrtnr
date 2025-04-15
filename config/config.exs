import Config

config :shrtnr, Shrtnr.Repo,
  database: "shrtnr_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :shrtnr, ecto_repos: [Shrtnr.Repo]

import_config "#{config_env()}.exs"
