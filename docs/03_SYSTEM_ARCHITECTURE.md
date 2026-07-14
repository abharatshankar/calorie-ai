# 🏗️ Calorie AI - System Design

Version: 1.0

---

# 1. High Level Architecture

```
                        Flutter App
                             │
                             ▼
                    API Layer (FastAPI)
                             │
                             ▼
                  Business Service Layer
                             │
                             ▼
                        AI Engine
                             │
      ┌──────────────────────┼─────────────────────┐
      │                      │                     │
      ▼                      ▼                     ▼
Prompt Manager      Image Processor      Response Parser
                             │
                             ▼
                  AI Provider Factory
                             │
                  ┌──────────┴──────────┐
                  ▼                     ▼
             OpenAI Vision        Gemini Vision
                             │
                             ▼
                        PostgreSQL
```

---

# 2. Components

## Flutter App

Responsibilities

- User Authentication
- Camera Access
- Gallery Upload
- Display AI Results
- Food History
- Daily Summary
- Profile Management

Flutter should never directly communicate with OpenAI or Gemini.

All communication must go through FastAPI.

---

## FastAPI Backend

Responsibilities

- JWT Authentication
- API Validation
- Business Logic
- Image Processing
- AI Communication
- Database Operations
- Error Handling

---

## AI Service Layer

Purpose

The AI Service Layer abstracts all AI providers behind a common interface.

Advantages

- Easily switch providers
- Cleaner code
- Better testing
- Secure API keys
- Future extensibility

---

## PostgreSQL

Stores

- Users
- Food Logs
- Daily Summaries (future)
- User Preferences (future)

---

# 3. Request Flow

## Food Scan Flow

User

↓

Flutter Camera

↓

Image Capture

↓

Multipart Upload

↓

FastAPI

↓

Authentication

↓

Food Service

↓

AI Provider Factory

↓

OpenAI Vision

↓

Structured JSON Response

↓

Food Service

↓

Save Database

↓

Return Response

↓

Flutter UI

---

# 4. Authentication Flow

User Login

↓

Flutter

↓

POST /auth/login

↓

FastAPI

↓

Verify Password

↓

Generate JWT

↓

Return Access Token

↓

Flutter Secure Storage

↓

Authenticated Requests

---

# 5. AI Provider Flow

Business Service

↓

AI Engine

↓

Image Processor

↓

Prompt Manager

↓

Provider Factory

↓

OpenAI / Gemini

↓

Response Parser

↓

Validated DTO

↓

Business Service

---

# 6. Backend Layers

API Layer

↓

Service Layer

↓

Repository Layer

↓

Database Layer

Each layer has only one responsibility.

---

# 7. Repository Pattern

Controllers never access the database directly.

Correct Flow

API

↓

Service

↓

Repository

↓

Database

Benefits

- Easy testing
- Better maintainability
- Cleaner code

---

# 8. AI Provider Pattern

Interface

AIProvider

Methods

analyze_food(image)

Providers

OpenAIProvider

GeminiProvider

Future

ClaudeProvider

LocalModelProvider

FoodService never knows which provider is running.

---

# 9. Error Handling

Possible Errors

401 Unauthorized

403 Forbidden

404 Not Found

422 Validation Error

429 Rate Limit

500 Internal Server Error

503 AI Service Unavailable

Every error should return

- status
- message
- error_code

---

# 10. Security

Authentication

JWT

Passwords

BCrypt Hashing

API Keys

Stored in .env

HTTPS

Required

SQL Injection

Prevented using SQLAlchemy ORM

---

# 11. Scalability

Current

Single FastAPI Instance

Future

Docker

↓

Load Balancer

↓

Multiple FastAPI Instances

↓

Shared PostgreSQL

↓

Redis Cache

↓

Message Queue (Future)

---

# 12. Logging

Application Logs

Authentication Logs

AI Request Logs

Error Logs

Future

Structured JSON Logging

ELK Stack

---

# 13. Future Improvements

- Redis Caching
- Celery Background Jobs
- Image Compression
- Offline Queue
- AI Cost Monitoring
- Multi-language Support
- Voice Food Logging
- Barcode Scanner
- Wearable Device Integration

---

# 14. Design Principles

- Clean Architecture
- SOLID Principles
- Repository Pattern
- Dependency Injection
- Strategy Pattern (AI Providers)
- Factory Pattern (Provider Selection)
- Separation of Concerns
- Production Ready

---

# 15. Why This Architecture?

This architecture separates presentation, business logic, AI integration, and data persistence into independent layers.

Benefits

- Easy to maintain
- Easy to test
- Easy to scale
- Easy to replace AI providers
- Production-ready architecture
- Excellent for technical interviews