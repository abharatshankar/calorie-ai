from http import HTTPStatus

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.db.session import get_db_session
from app.models.user import User
from app.schemas.dashboard import DashboardResponse
from app.services.history import HistoryService

router = APIRouter(prefix="/dashboard")


def get_history_service(
    session: AsyncSession = Depends(get_db_session),
) -> HistoryService:
    return HistoryService(session)


@router.get(
    "",
    response_model=DashboardResponse,
    summary="Get user's nutrition dashboard",
    description=(
        "Returns daily, weekly, and monthly calorie summaries plus macronutrient "
        "totals and total meals."
    ),
    responses={HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"}},
)
async def get_dashboard(
    current_user: User = Depends(get_current_user),
    history_service: HistoryService = Depends(get_history_service),
) -> DashboardResponse:
    return await history_service.get_dashboard(user_id=current_user.id)
