from http import HTTPStatus
from uuid import UUID

import jwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db_session
from app.exceptions.base import AppException
from app.models.user import User
from app.repositories.users import UserRepository
from app.security.jwt import decode_token

bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    session: AsyncSession = Depends(get_db_session),
) -> User:
    if credentials is None:
        raise AppException(
            "Authentication credentials were not provided.",
            status_code=HTTPStatus.UNAUTHORIZED,
            error_code="not_authenticated",
        )

    try:
        payload = decode_token(credentials.credentials)
        token_type = payload.get("type")
        user_id = UUID(str(payload.get("sub")))
    except (jwt.PyJWTError, TypeError, ValueError) as exc:
        raise AppException(
            "Invalid authentication token.",
            status_code=HTTPStatus.UNAUTHORIZED,
            error_code="invalid_token",
        ) from exc

    if token_type != "access":
        raise AppException(
            "Invalid authentication token.",
            status_code=HTTPStatus.UNAUTHORIZED,
            error_code="invalid_token",
        )

    user = await UserRepository(session).get_by_id(user_id)
    if user is None or not user.is_active:
        raise AppException(
            "Authenticated user was not found.",
            status_code=HTTPStatus.UNAUTHORIZED,
            error_code="user_not_found",
        )

    return user
