import Config

config :shrtnr, Shrtnr.Repo,
  database: "shrtnr_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :shrtnr, port: 4001
