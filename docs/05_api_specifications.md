# 🔌 Calorie AI - API Specification

Version: 1.0

Base URL

/api/v1

Authentication

JWT Bearer Token

Content-Type

application/json

Image Upload

multipart/form-data

---

# API Standards

## Success Response

{
    "success": true,
    "message": "Request successful",
    "data": {}
}

---

## Error Response

{
    "success": false,
    "message": "Invalid credentials",
    "error_code": "AUTH_001"
}

---

# Authentication APIs

## Register

POST

/api/v1/auth/register

Authentication

No

Request

{
    "name":"John Doe",
    "email":"john@gmail.com",
    "password":"Password@123"
}

Response

{
    "success":true,
    "message":"User registered successfully"
}

---

## Login

POST

/api/v1/auth/login

Request

{
    "email":"john@gmail.com",
    "password":"Password@123"
}

Response

{
    "success":true,
    "data":{
        "access_token":"",
        "token_type":"Bearer"
    }
}

---

## Current User

GET

/api/v1/users/me

Authentication

Required

Response

{
    "id":"",
    "name":"",
    "email":""
}

---

# Food APIs


## Analyze Food

POST

/api/v1/food/analyze

Authentication

Optional

Guest users can also access.

Content-Type

multipart/form-data

Request

Field

image

Type

File

Description

Food image captured using camera or selected from gallery.

---

Backend Processing Flow

Flutter

↓

POST /api/v1/food/analyze

↓

Food Controller

↓

Food Service

↓

AI Engine

↓

Image Processor

↓

Prompt Manager

↓

AI Provider Factory

↓

OpenAI Vision / Gemini Vision

↓

Response Parser

↓

Validated Food DTO

↓

Save History (Authenticated Users Only)

↓

Return API Response

---

Response

{
    "success": true,
    "message": "Food analyzed successfully",
    "data": {
        "food_name": "Chicken Biryani",
        "portion": "1 Plate",
        "calories": 850,
        "protein": 32,
        "carbs": 81,
        "fat": 26,
        "confidence": 0.94,
        "nutrition_summary": "High Protein Meal",
        "recommendation": "Eat vegetables along with this meal."
    }
}

---

## Food History

GET

/api/v1/food/history

Authentication

Required

Query Parameters

page

limit

date(optional)

Response

[
    {
        "food_name":"Dosa",
        "calories":220,
        "created_at":"..."
    }
]

---

## Delete Food Log

DELETE

/api/v1/food/{id}

Authentication

Required

Response

{
    "success":true,
    "message":"Deleted Successfully"
}

---

# Summary APIs

## Today's Summary

GET

/api/v1/summary/today

Authentication

Required

Response

{
    "total_calories":1850,
    "protein":95,
    "carbs":170,
    "fat":55
}

---

# Health Check

GET

/api/v1/health

Authentication

No

Response

{
    "status":"healthy"
}

---

# AI Engine Integration

# AI Engine Integration

The Food Analysis API does not communicate directly with AI providers.

Instead, all requests pass through the AI Engine.

Processing Pipeline

API Layer

↓

Business Service

↓

AI Engine

↓

Image Processor

↓

Prompt Manager

↓

AI Provider Factory

↓

OpenAI / Gemini

↓

Response Parser

↓

Validated DTO

↓

API Response

Benefits

- Provider Independent
- Centralized Prompt Management
- Response Validation
- Easier Testing
- Better Maintainability

# Status Codes

200 OK

201 Created

400 Bad Request

401 Unauthorized

403 Forbidden

404 Not Found

422 Validation Error

429 Too Many Requests

500 Internal Server Error

503 AI Service Unavailable

---

# Versioning Strategy

Current

v1

Future

v2

All APIs should support versioning.

---

# Security

JWT Authentication

BCrypt Password Hashing

HTTPS Only

Input Validation

Response Validation

Environment-based API Keys

Rate Limiting (Future)

# API Architecture

Every API follows the same internal processing pipeline.

Client

↓

API Router

↓

Service Layer

↓

AI Engine (if required)

↓

Repository

↓

Database

↓

Response DTO

↓

Client

Business logic must never exist inside API routes.

Repositories must never call AI providers directly.

All AI communication must go through the AI Engine.
