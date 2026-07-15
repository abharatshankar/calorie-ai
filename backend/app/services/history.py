from datetime import date
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions.base import AppException
from app.repositories.history import HistoryRepository
from app.schemas.dashboard import DashboardResponse
from app.schemas.foods import FoodLogListResponse, FoodLogResponse


class HistoryService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.history = HistoryRepository(session)

    async def list_for_user(
        self,
        *,
        user_id: UUID,
        page: int,
        size: int,
        search: str | None,
        start_date: date | None,
        end_date: date | None,
    ) -> FoodLogListResponse:
        total = await self.history.count_by_user(
            user_id=user_id,
            search=search,
            start_date=start_date,
            end_date=end_date,
        )
        items = await self.history.list_by_user(
            user_id=user_id,
            page=page,
            size=size,
            search=search,
            start_date=start_date,
            end_date=end_date,
        )
        pages = (total + size - 1) // size if total else 0

        return FoodLogListResponse(
            items=items,
            total=total,
            page=page,
            size=size,
            pages=pages,
        )

    async def get_for_user(self, *, history_id: UUID, user_id: UUID) -> FoodLogResponse:
        history_item = await self.history.get_by_id_for_user(
            history_id=history_id,
            user_id=user_id,
        )
        if history_item is None:
            raise AppException(
                "History entry was not found.",
                status_code=404,
                error_code="history_not_found",
            )
        return history_item

    async def delete_for_user(self, *, history_id: UUID, user_id: UUID) -> None:
        deleted = await self.history.delete_by_id_for_user(
            history_id=history_id,
            user_id=user_id,
        )
        if not deleted:
            raise AppException(
                "History entry was not found.",
                status_code=404,
                error_code="history_not_found",
            )
        await self.session.commit()

    async def get_dashboard(self, *, user_id: UUID) -> DashboardResponse:
        summary = await self.history.get_dashboard_summary(user_id=user_id)
        return DashboardResponse(
            today_calories=int(summary["today_calories"]),
            weekly_calories=int(summary["weekly_calories"]),
            monthly_calories=int(summary["monthly_calories"]),
            average_calories=float(summary["average_calories"]),
            protein_total=float(summary["protein_total"]),
            carbs_total=float(summary["carbs_total"]),
            fat_total=float(summary["fat_total"]),
            total_meals=int(summary["total_meals"]),
        )
