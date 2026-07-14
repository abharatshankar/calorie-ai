from datetime import date
from http import HTTPStatus
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.db.session import get_db_session
from app.models.user import User
from app.schemas.foods import FoodLogListPublicResponse, FoodLogPublicResponse
from app.services.history import HistoryService

router = APIRouter(prefix="/history")


def get_history_service(
    session: AsyncSession = Depends(get_db_session),
) -> HistoryService:
    return HistoryService(session)


@router.get(
    "",
    response_model=FoodLogListPublicResponse,
    summary="List food history entries",
    description=(
        "Returns the authenticated user's food history with pagination, search, "
        "date filters, and latest sorting."
    ),
    responses={HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"}},
)
async def list_history(
    page: int = Query(default=1, ge=1, description="Page number starting from 1"),
    size: int = Query(default=20, ge=1, le=100, description="Number of items per page"),
    search: str | None = Query(
        default=None,
        min_length=1,
        max_length=255,
        description="Search by detected food name",
    ),
    start_date: date | None = Query(
        default=None,
        description="Filter history entries created on or after this date",
    ),
    end_date: date | None = Query(
        default=None,
        description="Filter history entries created on or before this date",
    ),
    current_user: User = Depends(get_current_user),
    history_service: HistoryService = Depends(get_history_service),
) -> FoodLogListPublicResponse:
    return await history_service.list_for_user(
        user_id=current_user.id,
        page=page,
        size=size,
        search=search,
        start_date=start_date,
        end_date=end_date,
    )


@router.get(
    "/{id}",
    response_model=FoodLogPublicResponse,
    summary="Get a history entry by ID",
    responses={
        HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"},
        HTTPStatus.NOT_FOUND: {"description": "History entry not found"},
    },
)
async def get_history_item(
    id: UUID,
    current_user: User = Depends(get_current_user),
    history_service: HistoryService = Depends(get_history_service),
) -> FoodLogPublicResponse:
    return await history_service.get_for_user(
        history_id=id,
        user_id=current_user.id,
    )


@router.delete(
    "/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a history entry by ID",
    responses={
        HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"},
        HTTPStatus.NOT_FOUND: {"description": "History entry not found"},
    },
)
async def delete_history_item(
    id: UUID,
    current_user: User = Depends(get_current_user),
    history_service: HistoryService = Depends(get_history_service),
) -> None:
    await history_service.delete_for_user(history_id=id, user_id=current_user.id)
