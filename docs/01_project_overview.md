# 🍽️ CalorieAI

## Overview

CalorieAI is an AI-powered mobile application that helps users estimate the calories and nutritional information of their meals by simply taking a photo or uploading an image.

The application leverages Vision Language Models (LLMs) to identify food items, estimate portion sizes, calculate calories, and provide nutritional insights.

The goal is to make calorie tracking effortless without requiring users to manually search or enter food items.

---

## Problem Statement

Most calorie tracking applications require users to manually search for food items, select serving sizes, and enter quantities.

This process is tedious and often discourages users from maintaining consistent food logs.

CalorieAI solves this problem by allowing users to simply capture an image of their meal.

---

## Solution

Using AI Vision models, the application automatically:

- Detects food items
- Estimates quantity
- Calculates calories
- Estimates Protein
- Estimates Carbohydrates
- Estimates Fat
- Stores history for logged-in users

---

## Target Users

- Fitness Enthusiasts
- Weight Loss Users
- Gym Members
- Dieticians
- General Health Conscious Users

---

## Core Features

### Guest Mode

- No Login Required
- Scan Food
- View Calories
- No History Saved

### Logged-in User

- Login/Register
- Scan Food
- Save History
- Daily Summary
- Weekly Summary
- Nutrition Insights

---

## AI Features

- Food Recognition
- Portion Estimation
- Nutrition Estimation
- Daily Recommendations
- AI Health Insights (Future)

---

## Tech Stack

### Frontend

- Flutter
- Riverpod
- Clean Architecture

### Backend

- FastAPI
- SQLAlchemy
- PostgreSQL
- JWT Authentication

### AI

- OpenAI Vision API (initially)
- Gemini Vision (optional)
- Structured JSON Output

---

## MVP Goal

Complete a production-ready MVP within 10 days.

The application should be deployable and usable by real users.