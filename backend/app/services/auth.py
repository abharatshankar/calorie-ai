import asyncio
import logging
from datetime import UTC, datetime, timedelta
from http import HTTPStatus

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.config.settings import settings
from app.exceptions.base import AppException
from app.models.user import User
from app.repositories.refresh_tokens import RefreshTokenRepository
from app.repositories.users import UserRepository
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse
from app.security.jwt import access_token_expires_in_seconds, create_access_token
from app.security.password import hash_password, verify_password
from app.security.tokens import create_opaque_token, hash_token

logger = logging.getLogger(__name__)


class AuthService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.users = UserRepository(session)
        self.refresh_tokens = RefreshTokenRepository(session)

    async def register(self, payload: RegisterRequest) -> User:
        existing_user = await self.users.get_by_email(payload.email)
        if existing_user is not None:
            raise AppException(
                "A user with this email already exists.",
                status_code=HTTPStatus.CONFLICT,
                error_code="email_already_registered",
            )

        hashed_password = await asyncio.to_thread(hash_password, payload.password)
        user = await self.users.create(
            email=str(payload.email),
            hashed_password=hashed_password,
            full_name=payload.full_name,
        )

        try:
            await self.session.commit()
        except IntegrityError as exc:
            await self.session.rollback()
            logger.warning("User registration race detected on unique email constraint")
            raise AppException(
                "A user with this email already exists.",
                status_code=HTTPStatus.CONFLICT,
                error_code="email_already_registered",
            ) from exc

        logger.info("User registered: user_id=%s", user.id)
        return user

    async def login(self, payload: LoginRequest) -> TokenResponse:
        user = await self.users.get_by_email(payload.email)
        password_matches = user is not None and await asyncio.to_thread(
            verify_password, payload.password, user.hashed_password
        )
        if user is None or not password_matches:
            raise AppException(
                "Invalid email or password.",
                status_code=HTTPStatus.UNAUTHORIZED,
                error_code="invalid_credentials",
            )

        if not user.is_active:
            raise AppException(
                "User account is inactive.",
                status_code=HTTPStatus.FORBIDDEN,
                error_code="inactive_user",
            )

        token_response = await self._issue_tokens(user)
        await self.session.commit()
        logger.info("User logged in: user_id=%s", user.id)
        return token_response

    async def refresh(self, refresh_token: str) -> TokenResponse:
        stored_token = await self.refresh_tokens.get_active_by_hash(hash_token(refresh_token))
        if stored_token is None:
            raise AppException(
                "Invalid or expired refresh token.",
                status_code=HTTPStatus.UNAUTHORIZED,
                error_code="invalid_refresh_token",
            )

        user = await self.users.get_by_id(stored_token.user_id)
        if user is None or not user.is_active:
            raise AppException(
                "Invalid or expired refresh token.",
                status_code=HTTPStatus.UNAUTHORIZED,
                error_code="invalid_refresh_token",
            )

        await self.refresh_tokens.revoke(stored_token)
        token_response = await self._issue_tokens(user)
        await self.session.commit()
        logger.info("Refresh token rotated: user_id=%s", user.id)
        return token_response

    async def _issue_tokens(self, user: User) -> TokenResponse:
        access_token = create_access_token(user.id)
        refresh_token = create_opaque_token()
        expires_at = datetime.now(UTC) + timedelta(days=settings.refresh_token_expire_days)

        await self.refresh_tokens.create(
            user_id=user.id,
            token_hash=hash_token(refresh_token),
            expires_at=expires_at,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=access_token_expires_in_seconds(),
        )
