# Calorie AI Backend

Production-ready FastAPI backend for the AI-powered calorie tracking application.

## Overview

This backend provides:
- JWT-based authentication
- Food logging and history
- AI image nutrition analysis using OpenAI Vision
- PostgreSQL persistence with SQLAlchemy Async
- Alembic migrations
- OpenAPI documentation via Swagger

## Prerequisites

- Python 3.12
- PostgreSQL
- [`uvicorn`](https://www.uvicorn.org/) for local development
- OpenAI API key

## Setup

```bash
cd /Users/madhurikarthik/Documents/calorie_ai/backend
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e .
```

## Environment Variables

Create a `.env` file at the backend root with the following values:

```env
APP_NAME=Calorie AI
APP_ENV=development
APP_VERSION=0.1.0
APP_DESCRIPTION=AI-powered calorie tracking backend
DEBUG=true
POSTGRES_DB=your_db
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
DATABASE_URL=postgresql+asyncpg://your_user:your_password@localhost:5432/your_db
JWT_SECRET_KEY=your_access_secret
JWT_REFRESH_SECRET_KEY=your_refresh_secret
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=30
OPENAI_API_KEY=your_openai_api_key
OPENAI_VISION_MODEL=gpt-image-1
```

> Note: `DATABASE_URL` is required by both the app and Alembic.

## Database Migrations

Run migrations before starting the app:

```bash
cd /Users/madhurikarthik/Documents/calorie_ai/backend
source .venv/bin/activate
alembic upgrade head
```

## Run the App

```bash
cd /Users/madhurikarthik/Documents/calorie_ai/backend
source .venv/bin/activate
uvicorn app.main:app --reload
```

## API Documentation

Swagger UI is available at:

```
http://localhost:8000/docs
```

## How to Test

### Authentication
1. Register via `POST /api/v1/auth/register`
2. Login via `POST /api/v1/auth/login`
3. Copy the returned `access_token`
4. Click `Authorize` in Swagger and paste `Bearer <access_token>`

### Food History
- `GET /api/v1/history`
- `GET /api/v1/history/{id}`
- `DELETE /api/v1/history/{id}`

### Dashboard
- `GET /api/v1/dashboard`

### AI Food Analysis
- `POST /api/v1/foods/analyze`
- Attach an image file in the request body

## Production Notes

- Use environment variables to store secrets.
- Use a managed object storage or CDN for production image uploads instead of local `uploads/`.
- Ensure proper database backups and monitoring.
- Run the app behind a production-grade ASGI server or load balancer.
