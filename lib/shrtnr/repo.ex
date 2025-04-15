defmodule Shrtnr.Repo do
  use Ecto.Repo,
    otp_app: :shrtnr,
    adapter: Ecto.Adapters.Postgres
end
