import pytest

from app.config.settings import Settings


def _settings_kwargs(**overrides: object) -> dict[str, object]:
    base: dict[str, object] = {
        "APP_NAME": "Calorie AI",
        "APP_ENV": "production",
        "APP_VERSION": "1.0.0",
        "APP_DESCRIPTION": "test",
        "DEBUG": "false",
        "POSTGRES_DB": "db",
        "POSTGRES_USER": "user",
        "POSTGRES_PASSWORD": "password",
        "POSTGRES_HOST": "localhost",
        "POSTGRES_PORT": "5432",
        "DATABASE_URL": "postgresql+asyncpg://user:password@localhost:5432/db",
        "JWT_SECRET_KEY": "a" * 40,
        "JWT_REFRESH_SECRET_KEY": "b" * 40,
        "JWT_ALGORITHM": "HS256",
        "ACCESS_TOKEN_EXPIRE_MINUTES": "30",
        "REFRESH_TOKEN_EXPIRE_DAYS": "7",
        "OPENAI_API_KEY": "test-key",
        "OPENAI_VISION_MODEL": "gpt-4.1-mini",
    }
    base.update(overrides)
    return base


def test_strong_production_settings_are_accepted() -> None:
    settings = Settings(_env_file=None, **_settings_kwargs())
    assert settings.is_production is True


def test_placeholder_secret_rejected_in_production() -> None:
    with pytest.raises(ValueError):
        Settings(
            _env_file=None,
            **_settings_kwargs(JWT_SECRET_KEY="local-development-secret-change-before-production"),
        )


def test_short_secret_rejected_in_production() -> None:
    with pytest.raises(ValueError):
        Settings(_env_file=None, **_settings_kwargs(JWT_SECRET_KEY="too-short"))


def test_identical_jwt_secrets_rejected_in_production() -> None:
    with pytest.raises(ValueError):
        Settings(_env_file=None, **_settings_kwargs(JWT_REFRESH_SECRET_KEY="a" * 40))


def test_wildcard_cors_origin_rejected() -> None:
    with pytest.raises(ValueError):
        Settings(_env_file=None, **_settings_kwargs(CORS_ORIGINS="*"))


def test_cors_origins_parsed_from_csv() -> None:
    settings = Settings(
        _env_file=None,
        **_settings_kwargs(CORS_ORIGINS="https://a.com, https://b.com"),
    )
    assert settings.cors_origins == ["https://a.com", "https://b.com"]
