# Calorie AI — Backend

A FastAPI backend for an AI-powered calorie tracking app. Users upload a photo of a
meal, an OpenAI vision model estimates its nutrition, and results are stored and
surfaced through history and dashboard endpoints.

**Stack:** FastAPI · SQLAlchemy 2.0 (async) · asyncpg · PostgreSQL · Pydantic v2 ·
Alembic · PyJWT · bcrypt · OpenAI · Uvicorn

---

## Features

- JWT authentication with rotating, hashed refresh tokens
- AI meal-image nutrition analysis (OpenAI vision), with the raw provider response
  retained server-side but never exposed to clients
- Food logging, searchable/paginated history, and a nutrition dashboard
- Async database access with a clean API → service → repository layering
- Centralized error handling with a consistent `{ detail, error_code }` envelope
- Configurable CORS, security headers, auth rate limiting, and secret-strength
  validation that fails fast in production
- Versioned schema via Alembic migrations

---

## Project structure

```
backend/
├── app/
│   ├── api/
│   │   ├── dependencies/   # shared deps: auth, rate limiting, upload validation
│   │   └── v1/             # versioned routers (auth, foods, history, dashboard, ...)
│   ├── config/             # settings + constants
│   ├── core/               # logging setup
│   ├── db/                 # engine, session, declarative base
│   ├── exceptions/         # AppException + handlers
│   ├── models/             # SQLAlchemy ORM models
│   ├── providers/          # AIProvider abstraction + OpenAI implementation
│   ├── repositories/       # data-access layer
│   ├── schemas/            # Pydantic request/response models
│   ├── security/           # JWT, password hashing, opaque tokens
│   ├── services/           # business logic
│   └── main.py             # app factory, middleware, router wiring
├── alembic/                # migration environment + versions
├── tests/                  # pytest suite
├── docker-compose.yml      # PostgreSQL (+ optional pgAdmin) for local dev
└── pyproject.toml
```

---

## Prerequisites

- Python 3.12
- PostgreSQL 16 (or use the bundled `docker-compose.yml`)
- An OpenAI API key

---

## Getting started

### 1. Install dependencies

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

### 2. Configure environment

Copy the example file and fill in your values:

```bash
cp .env.example .env
```

See [Configuration](#configuration) for the full list of variables.

### 3. Start PostgreSQL

Using Docker (recommended for local dev):

```bash
docker compose up -d postgres
```

### 4. Run migrations

```bash
alembic upgrade head
```

### 5. Run the API

```bash
uvicorn app.main:app --reload
```

The API is available at `http://localhost:8000`. Interactive docs (Swagger UI) are
served at `http://localhost:8000/docs` **when `DEBUG` is enabled** — they are
disabled automatically in production.

---

## Configuration

All configuration is provided via environment variables (loaded from `.env`).

| Variable | Description | Example |
|---|---|---|
| `APP_NAME` | Application name | `Calorie AI Backend` |
| `APP_ENV` | `development` / `production` | `development` |
| `APP_VERSION` | Semantic version | `0.1.0` |
| `APP_DESCRIPTION` | Description shown in OpenAPI | `AI Nutrition Backend` |
| `DEBUG` | Verbose logging + docs exposure | `true` |
| `CORS_ORIGINS` | Comma-separated allowed origins (empty = disabled) | `https://app.example.com` |
| `POSTGRES_DB` / `POSTGRES_USER` / `POSTGRES_PASSWORD` | Database credentials | — |
| `POSTGRES_HOST` / `POSTGRES_PORT` | Database host/port | `localhost` / `5432` |
| `DATABASE_URL` | Async SQLAlchemy URL (used by app **and** Alembic) | `postgresql+asyncpg://user:pass@localhost:5432/calorie_ai` |
| `DB_POOL_SIZE` / `DB_MAX_OVERFLOW` | Connection pool tuning | `10` / `20` |
| `JWT_SECRET_KEY` / `JWT_REFRESH_SECRET_KEY` | JWT signing secrets (≥32 chars in prod) | — |
| `JWT_ALGORITHM` | JWT algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Access token lifetime | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Refresh token lifetime | `7` |
| `OPENAI_API_KEY` | OpenAI API key | — |
| `OPENAI_VISION_MODEL` | Vision-capable model | `gpt-4.1-mini` |
| `OPENAI_TIMEOUT_SECONDS` / `OPENAI_MAX_RETRIES` | Upstream call bounds | `30` / `2` |

> In production (`APP_ENV=production`) the app refuses to start with placeholder or
> weak JWT secrets, with `DEBUG` enabled, or with a wildcard CORS origin.

---

## Testing

```bash
pytest
```

The suite covers security primitives (password hashing, JWT round-trips),
configuration invariants, and the health endpoint. It does not require a database.

---

## API overview

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/auth/register` | Create an account |
| `POST` | `/api/v1/auth/login` | Obtain access + refresh tokens |
| `POST` | `/api/v1/auth/refresh` | Rotate a refresh token |
| `GET`  | `/api/v1/auth/me` | Current user |
| `POST` | `/api/v1/upload` | Upload a food image |
| `POST` | `/api/v1/foods/analyze` | Analyze an image and log the result |
| `GET`  | `/api/v1/foods` | List food logs (paginated, searchable) |
| `GET`/`DELETE` | `/api/v1/foods/{id}` | Fetch / delete a food log |
| `GET`  | `/api/v1/history` | Food history (date filters) |
| `GET`  | `/api/v1/dashboard` | Nutrition summary |
| `GET`  | `/api/v1/health` | Health check |

Authenticate by sending `Authorization: Bearer <access_token>`.

---

## Code quality

```bash
ruff check .        # lint
ruff format .       # format
mypy app            # type-check
```

---

## Production notes

- Store secrets in a secrets manager, never in the image or repo.
- Use managed object storage / a CDN for uploads instead of the local `uploads/` dir.
- Move rate limiting to a shared store (e.g. Redis) when running multiple workers.
- Run behind a production ASGI setup (e.g. `uvicorn`/`gunicorn` workers) and a proxy
  that enforces request body-size limits and TLS.

---

## License

Released under the [MIT License](LICENSE).
