# 🗄️ Calorie AI - Database Design

Version: 1.0

---

# 1. Overview

PostgreSQL is the primary database for Calorie AI.

The database is designed to:

- Store user information securely.
- Store food scan history.
- Support future analytics.
- Scale for production workloads.
- Minimize redundant data.

---

# 2. Entity Relationship Diagram (ERD)

```
+----------------+
|     users      |
+----------------+
| id             |
| name           |
| email          |
| password_hash  |
| created_at     |
| updated_at     |
+--------+-------+
         |
         | 1
         |
         | N
+--------v--------------------+
|         food_logs           |
+-----------------------------+
| id                          |
| user_id (FK)                |
| image_url                   |
| food_name                   |
| portion                     |
| calories                    |
| protein                     |
| carbs                       |
| fat                         |
| confidence                  |
| nutrition_summary           |
| recommendation              |
| created_at                  |
| updated_at                  |
+-----------------------------+
```

---

# 3. Users Table

## Purpose

Stores registered users.

## Columns

| Column | Type | Description |
|----------|---------|----------------|
| id | UUID | Primary Key |
| name | VARCHAR(100) | Full Name |
| email | VARCHAR(255) | Unique Email |
| password_hash | TEXT | BCrypt Hash |
| created_at | TIMESTAMP | Created Time |
| updated_at | TIMESTAMP | Updated Time |

---

# 4. Food Logs Table

## Purpose

Stores every food analysis performed by authenticated users.

## Columns

| Column | Type | Description |
|----------|---------|----------------|
| id | UUID | Primary Key |
| user_id | UUID | FK → users.id |
| image_url | TEXT | Uploaded Image URL |
| food_name | VARCHAR(255) | AI Detected Food |
| portion | VARCHAR(100) | Portion Size |
| calories | INTEGER | Estimated Calories |
| protein | DECIMAL(5,2) | Protein (g) |
| carbs | DECIMAL(5,2) | Carbohydrates (g) |
| fat | DECIMAL(5,2) | Fat (g) |
| confidence | DECIMAL(4,2) | AI Confidence Score |
| nutrition_summary | TEXT | AI Summary |
| recommendation | TEXT | AI Recommendation |
| created_at | TIMESTAMP | Scan Time |
| updated_at | TIMESTAMP | Last Updated |

---

# 5. Relationships

## Users → Food Logs

One User

↓

Many Food Logs

Relationship

users.id

↓

food_logs.user_id

---

# 6. Indexes

Users

- Unique Index on Email

Food Logs

- Index on user_id
- Index on created_at
- Composite Index (user_id, created_at)

These indexes optimize:

- Daily history
- Weekly history
- Monthly history

---

# 7. Constraints

Users

- Email must be unique.
- Password hash cannot be null.

Food Logs

- User ID must exist.
- Calories cannot be negative.
- Protein, Carbs, Fat cannot be negative.

---

# 8. Data Retention

Guest Users

- No data stored.

Registered Users

- Data stored permanently.
- Users may delete individual food logs.
- Future: Account deletion removes all related food logs.

---

# 9. Future Tables

## User Goals

Stores:

- Daily Calorie Goal
- Weight Goal
- Target Protein
- Target Carbs
- Target Fat

---

## Daily Summary

Stores pre-calculated totals.

Columns

- user_id
- date
- total_calories
- total_protein
- total_carbs
- total_fat

Purpose

Improves dashboard performance.

---

## AI Feedback

Stores AI-generated insights separately.

Future Benefits

- History of recommendations.
- Personalized coaching.
- Nutrition trends.

---

# 10. UUID Strategy

Every primary key uses UUID.

Benefits

- Better for distributed systems.
- Harder to guess IDs.
- Safer public APIs.

---

# 11. Timestamp Strategy

Every table includes:

- created_at
- updated_at

Benefits

- Auditing
- Debugging
- Analytics

---

# 12. Migration Strategy

Database changes will be managed using:

- Alembic
- SQLAlchemy ORM

Every schema modification must be version-controlled.

---

# 13. Future Scalability

Current

Flutter

↓

FastAPI

↓

PostgreSQL

Future

Flutter

↓

API Gateway

↓

FastAPI Cluster

↓

Redis Cache

↓

PostgreSQL Primary

↓

Read Replicas

---

# 14. Database Design Principles

- Normalize data where appropriate.
- Avoid duplicate information.
- Prefer UUID over auto-increment IDs.
- Use indexes for frequently queried fields.
- Keep schema extensible for future AI features.