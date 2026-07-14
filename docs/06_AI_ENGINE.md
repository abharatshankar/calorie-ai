# 🤖 Calorie AI - AI Engine Design

Version: 1.0

---

# 1. Overview

The AI Engine is the core intelligence layer of Calorie AI.

Instead of allowing business services to communicate directly with AI providers such as OpenAI or Gemini, all AI interactions must pass through the AI Engine.

The AI Engine provides a unified interface for food image analysis while hiding provider-specific implementation details.

Benefits:

- Separation of Concerns
- Provider Independence
- Centralized Prompt Management
- Response Validation
- Easier Testing
- Better Maintainability

---

# 2. High Level Flow

Flutter

↓

FastAPI API Layer

↓

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

AI Provider

↓

Response Parser

↓

DTO

↓

Business Service

↓

Database

↓

Response

---

# 3. Responsibilities

The AI Engine is responsible for:

- Receiving image data
- Validating images
- Optimizing images
- Loading prompts
- Selecting AI provider
- Sending AI request
- Parsing AI response
- Validating response
- Returning standardized DTO

---

# 4. Components

## AI Engine

Entry point for all AI operations.

Example

analyze_food(image)

---

## Image Processor

Responsibilities

- Validate image
- Resize image
- Compress image
- Convert formats if required

---

## Prompt Manager

Responsibilities

- Store prompts
- Version prompts
- Load prompts
- Support future prompt variants

---

## Provider Factory

Responsibilities

- Select configured AI provider
- Create provider instance
- Hide provider implementation

Supported Providers

- OpenAI
- Gemini

Future

- Claude
- Local Models

---

## Response Parser

Responsibilities

- Parse AI response
- Validate JSON
- Handle malformed responses
- Convert to internal DTO

---

# 5. Design Principles

The AI Engine follows:

- Single Responsibility Principle
- Strategy Pattern
- Factory Pattern
- Dependency Injection
- Open/Closed Principle

---

# 6. Public Interface

The rest of the application only interacts with:

analyze_food(image)

No other AI component should be called directly.

---

# 7. Future Enhancements

- OCR Support
- Barcode Recognition
- Meal Classification
- AI Cost Tracking
- AI Retry Logic
- AI Caching
- Multi-step AI Pipelines

---

# 8. Engineering Decision

Why an AI Engine?

Instead of calling OpenAI directly from business services, the AI Engine provides a stable abstraction.

This allows provider replacement, centralized prompt management, standardized responses, and easier testing without affecting business logic.