# Shrtnr

A simple URL shortener built in Elixir using Plug, Bandit, and Ecto with PostgreSQL.

---

## ✅ Requirements Checklist

- [x] Root path `/` serves a form to paste a URL
- [x] Submitting a valid URL returns a short link (`/{slug}`)
- [x] Navigating to `/{slug}` redirects to the original URL
- [x] Only allows valid URLs (must start with `http://` or `https://`)
- [x] `/stats` page lists each short URL, original URL, and visit count
- [x] `/stats.csv` returns a downloadable CSV of stats data
- [x] No user login or authentication
- [x] Handles 5 req/s to form submission, 25 req/s to redirect endpoint
- [x] Uses a persistent data store (PostgreSQL)
- [x] Includes test cases for application logic
- [x] Includes setup and test instructions in `README.md`
- [x] Uses a single repo with Docker-based setup (one docker-compose file)

---

## 🧪 Local Development

Install dependencies:

```bash
mix deps.get
mix ecto.setup
mix run --no-halt
```

Visit: [http://localhost:8080](http://localhost:8080)

Run tests:

```bash
MIX_ENV=test mix deps.get
MIX_ENV=test mix ecto.setup
MIX_ENV=test mix test
```

Just a note: Local development, tests, and benchmarking will expect to connect to Postgres on port 5432 and have the correct databases. The docker deploy includes a Postgres server but its port is not mapped to localhost. 

---

## 📈 Benchmarking

You can run the included benchmark to test performance at increasing request loads.

First ensure the database is created and migrated:

```bash
MIX_ENV=benchmark mix ecto.setup
```

Then run the benchmark:

```bash
MIX_ENV=benchmark mix run bench/benchmark.exs
```

The benchmark performs both POST and GET requests with logarithmic growth (10, 100, 1000), printing requests per second (RPS) metrics for GETs and POSTs.

---

## 🐳 Docker Deployment

Build and start the app:

```bash
docker compose up --build
```

This runs a multi-stage Elixir release with automatic database migrations.

Visit: [http://localhost:8080](http://localhost:8080)

Inspect the app container:

```bash
docker compose exec web bin/shrtnr remote
```

Run migrations manually (if needed):

```bash
docker compose exec web bin/shrtnr eval "Ecto.Migrator.with_repo(Shrtnr.Repo, &Ecto.Migrator.run(&1, :up, all: true))"
```

---

## 🛠 Tech Stack

- Elixir 1.17
- Plug + Bandit (no Phoenix)
- Ecto + PostgreSQL
- OTP Release-based Docker container

---

## 📝 Assumptions

- Duplicate original URLs are allowed
- Slugs are generated, not user-defined
- URL validation is format-based only
- Visit counts are updated atomically in the database
- Server-rendered HTML, no JS or client-side rendering

---

## 📂 Project Structure

```
lib/
├── shrtnr/
│   ├── link.ex       # Business logic (creation, redirects, counts)
│   ├── slug.ex       # Random slug generation with collision retry
│   ├── html.ex       # HTML rendering for form, result, and stats
│   └── benchmark.ex  # Load generation and RPS reporting
├── repo.ex           # Ecto repo
└── router.ex         # Plug router and HTTP entrypoints
```

---

## ✅ Submission Notes

- Fully tested
- Release-based Docker deployment
- Minimal, idiomatic Elixir without Phoenix
- Clean separation of concerns
- SSR HTML pages with simple styling

Thanks for reviewing!

