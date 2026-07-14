from http import HTTPStatus

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.api.dependencies.rate_limit import auth_rate_limit
from app.db.session import get_db_session
from app.models.user import User
from app.schemas.auth import (
    LoginRequest,
    RefreshTokenRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)
from app.services.auth import AuthService

router = APIRouter(prefix="/auth")


def get_auth_service(
    session: AsyncSession = Depends(get_db_session),
) -> AuthService:
    return AuthService(session)


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
    dependencies=[Depends(auth_rate_limit)],
    responses={HTTPStatus.CONFLICT: {"description": "Email already registered"}},
)
async def register(
    payload: RegisterRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> User:
    return await auth_service.register(payload)


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Authenticate a user",
    dependencies=[Depends(auth_rate_limit)],
    responses={HTTPStatus.UNAUTHORIZED: {"description": "Invalid credentials"}},
)
async def login(
    payload: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> TokenResponse:
    return await auth_service.login(payload)


@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Rotate a refresh token",
    dependencies=[Depends(auth_rate_limit)],
    responses={HTTPStatus.UNAUTHORIZED: {"description": "Invalid refresh token"}},
)
async def refresh(
    payload: RefreshTokenRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> TokenResponse:
    return await auth_service.refresh(payload.refresh_token)


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Return the current authenticated user",
    responses={HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"}},
)
async def get_me(current_user: User = Depends(get_current_user)) -> User:
    return current_user
