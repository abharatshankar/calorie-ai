# Calorie AI

Snap a photo of a meal, get an AI-powered nutrition estimate, and track your intake
over time. Calorie AI is a full-stack project pairing a **FastAPI** backend with a
**Flutter** cross-platform client.

## Overview

| Component | Stack | Location |
|---|---|---|
| Backend API | FastAPI · SQLAlchemy 2.0 (async) · PostgreSQL · OpenAI vision | [`backend/`](backend/) |
| Mobile / web client | Flutter (clean architecture) | [`frontend/`](frontend/) |
| Design docs | Requirements, architecture, DB & API specs | [`docs/`](docs/) |

## How it works

1. A user uploads a meal image from the Flutter client.
2. The backend validates and stores the image, then sends it to an OpenAI vision
   model with a strict JSON schema.
3. The estimated nutrition is persisted and returned; history and a dashboard
   aggregate the user's intake.

## Getting started

Each component has its own setup instructions:

- **Backend:** see [`backend/README.md`](backend/README.md)
- **Frontend:** see [`frontend/README.md`](frontend/README.md)

For local development, start the database and API from `backend/`, then run the
Flutter app pointing at the local API.

## Documentation

Product and engineering design documents live in [`docs/`](docs/), covering the
project overview, software requirements, system architecture, database design,
API specifications, and the AI/prompt engineering approach.

## License

The backend is released under the [MIT License](backend/LICENSE).
