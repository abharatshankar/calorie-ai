from functools import lru_cache
from pathlib import Path
from typing import Any

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

ENV_FILE = Path(__file__).resolve().parents[2] / ".env"

MIN_JWT_SECRET_LENGTH = 32
# Tokens/passwords shipped in the repo templates must never survive into a
# non-development deployment.
_INSECURE_SECRET_MARKERS = ("change", "replace", "local-development", "example", "secret-key")


class Settings(BaseSettings):
    """Application configuration loaded from environment variables."""

    app_name: str = Field(validation_alias="APP_NAME")
    app_env: str = Field(validation_alias="APP_ENV")
    app_version: str = Field(validation_alias="APP_VERSION")
    app_description: str = Field(validation_alias="APP_DESCRIPTION")
    debug: bool = Field(validation_alias="DEBUG")

    postgres_db: str = Field(validation_alias="POSTGRES_DB")
    postgres_user: str = Field(validation_alias="POSTGRES_USER")
    postgres_password: str = Field(validation_alias="POSTGRES_PASSWORD")
    postgres_host: str = Field(validation_alias="POSTGRES_HOST")
    postgres_port: int = Field(validation_alias="POSTGRES_PORT")
    database_url: str = Field(validation_alias="DATABASE_URL")
    db_pool_size: int = Field(default=10, validation_alias="DB_POOL_SIZE")
    db_max_overflow: int = Field(default=20, validation_alias="DB_MAX_OVERFLOW")

    jwt_secret_key: str = Field(validation_alias="JWT_SECRET_KEY")
    jwt_refresh_secret_key: str = Field(validation_alias="JWT_REFRESH_SECRET_KEY")
    jwt_algorithm: str = Field(validation_alias="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(validation_alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(validation_alias="REFRESH_TOKEN_EXPIRE_DAYS")
    openai_api_key: str = Field(validation_alias="OPENAI_API_KEY")
    openai_vision_model: str = Field(validation_alias="OPENAI_VISION_MODEL")
    openai_timeout_seconds: float = Field(default=30.0, validation_alias="OPENAI_TIMEOUT_SECONDS")
    openai_max_retries: int = Field(default=2, validation_alias="OPENAI_MAX_RETRIES")

    cors_origins: list[str] = Field(
        default_factory=list,
        validation_alias="CORS_ORIGINS",
        description="Comma-separated list of allowed CORS origins.",
    )

    @field_validator("cors_origins", mode="before")
    @classmethod
    def parse_cors_origins(cls, value: Any) -> Any:
        if isinstance(value, str):
            return [origin.strip() for origin in value.split(",") if origin.strip()]
        return value

    @field_validator("debug", mode="before")
    @classmethod
    def parse_debug(cls, value: Any) -> Any:
        if isinstance(value, str):
            normalized_value = value.strip().lower()
            if normalized_value in {"release", "prod", "production"}:
                return False
            if normalized_value in {"dev", "development"}:
                return True
        return value

    @property
    def is_production(self) -> bool:
        return self.app_env.strip().lower() in {"release", "prod", "production"}

    @model_validator(mode="after")
    def validate_security_invariants(self) -> "Settings":
        # In development we allow the checked-in placeholders so the app runs
        # out of the box, but a production environment must not.
        if self.is_production:
            self._assert_strong_secret("JWT_SECRET_KEY", self.jwt_secret_key)
            self._assert_strong_secret("JWT_REFRESH_SECRET_KEY", self.jwt_refresh_secret_key)
            if self.jwt_secret_key == self.jwt_refresh_secret_key:
                raise ValueError(
                    "JWT_SECRET_KEY and JWT_REFRESH_SECRET_KEY must differ in production."
                )
            if self.debug:
                raise ValueError("DEBUG must be disabled in production.")

        if self.cors_origins and "*" in self.cors_origins:
            # A wildcard origin combined with credentialed requests is rejected by
            # browsers and is a CSRF/exfiltration hazard; forbid it outright.
            raise ValueError(
                "CORS_ORIGINS must list explicit origins; '*' is not allowed with credentials."
            )
        return self

    @staticmethod
    def _assert_strong_secret(name: str, value: str) -> None:
        if len(value) < MIN_JWT_SECRET_LENGTH:
            raise ValueError(f"{name} must be at least {MIN_JWT_SECRET_LENGTH} characters.")
        lowered = value.lower()
        if any(marker in lowered for marker in _INSECURE_SECRET_MARKERS):
            raise ValueError(f"{name} still uses a placeholder/insecure value.")

    model_config = SettingsConfigDict(
        env_file=ENV_FILE,
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Return a cached settings instance."""
    return Settings()


settings = get_settings()
