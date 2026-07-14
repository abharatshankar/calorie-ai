.PHONY: help install db-up db-down migrate run test lint format typecheck check

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install the app with dev dependencies
	python -m pip install -e ".[dev]"

db-up: ## Start PostgreSQL via docker compose
	docker compose up -d postgres

db-down: ## Stop docker compose services
	docker compose down

migrate: ## Apply database migrations
	alembic upgrade head

run: ## Run the API with autoreload
	uvicorn app.main:app --reload

test: ## Run the test suite
	pytest

lint: ## Lint with ruff
	ruff check .

format: ## Format with ruff
	ruff format .

typecheck: ## Type-check with mypy
	mypy app

check: lint typecheck test ## Run lint, type-check and tests
