FROM elixir:1.17.3-otp-26-slim AS build

RUN apt-get update && apt-get install -y \
    ca-certificates curl gnupg postgresql-client locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    apt-get clean

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

WORKDIR /app
COPY . .

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix assets.deploy || true
RUN MIX_ENV=prod mix release

# --- runtime stage ---
FROM debian:trixie-slim AS app

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV MIX_ENV=prod
ENV HOME=/app
ENV DATABASE_URL=ecto://postgres:postgres@db/shrtnr_dev
ENV PORT=8080

WORKDIR /app
COPY --from=build /app/_build/prod/rel/shrtnr ./

EXPOSE 8080

CMD ["sh", "-c", "bin/shrtnr eval \"Ecto.Migrator.with_repo(Shrtnr.Repo, &Ecto.Migrator.run(&1, :up, all: true))\" && bin/shrtnr start"]
