import Config

config :shrtnr, Shrtnr.Repo,
  username: "postgres",
  password: "postgres",
  database: "shrtnr_benchmark",
  hostname: "localhost",
  pool_size: 50

config :shrtnr, port: 4002
