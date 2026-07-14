from datetime import date
from uuid import UUID

from sqlalchemy import case, delete, func, select, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import defer

from app.models.food_log import FoodLog


class HistoryRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list_by_user(
        self,
        *,
        user_id: UUID,
        page: int,
        size: int,
        search: str | None,
        start_date: date | None,
        end_date: date | None,
    ) -> list[FoodLog]:
        # ai_response is not part of the history payload; defer the JSONB column.
        query = (
            select(FoodLog).where(FoodLog.user_id == user_id).options(defer(FoodLog.ai_response))
        )

        if search:
            query = query.where(FoodLog.detected_food_name.ilike(f"%{search}%"))

        if start_date is not None:
            query = query.where(func.date(FoodLog.created_at) >= start_date)

        if end_date is not None:
            query = query.where(func.date(FoodLog.created_at) <= end_date)

        query = query.order_by(FoodLog.created_at.desc()).offset((page - 1) * size).limit(size)

        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def count_by_user(
        self,
        *,
        user_id: UUID,
        search: str | None,
        start_date: date | None,
        end_date: date | None,
    ) -> int:
        query = select(func.count()).select_from(FoodLog).where(FoodLog.user_id == user_id)

        if search:
            query = query.where(FoodLog.detected_food_name.ilike(f"%{search}%"))

        if start_date is not None:
            query = query.where(func.date(FoodLog.created_at) >= start_date)

        if end_date is not None:
            query = query.where(func.date(FoodLog.created_at) <= end_date)

        result = await self.session.execute(query)
        return result.scalar_one()

    async def get_by_id_for_user(self, *, history_id: UUID, user_id: UUID) -> FoodLog | None:
        result = await self.session.execute(
            select(FoodLog)
            .where(
                FoodLog.id == history_id,
                FoodLog.user_id == user_id,
            )
            .options(defer(FoodLog.ai_response))
        )
        return result.scalar_one_or_none()

    async def delete_by_id_for_user(self, *, history_id: UUID, user_id: UUID) -> bool:
        # Single-round-trip bulk delete instead of SELECT-then-delete.
        result = await self.session.execute(
            delete(FoodLog).where(
                FoodLog.id == history_id,
                FoodLog.user_id == user_id,
            )
        )
        return result.rowcount > 0

    async def get_dashboard_summary(self, *, user_id: UUID) -> dict[str, object]:
        today_calories = func.coalesce(
            func.sum(
                case(
                    (func.date(FoodLog.created_at) == func.current_date(), FoodLog.calories),
                    else_=0,
                )
            ),
            0,
        )
        seven_days_ago = func.now() - text("interval '7 days'")
        weekly_calories = func.coalesce(
            func.sum(
                case(
                    (FoodLog.created_at >= seven_days_ago, FoodLog.calories),
                    else_=0,
                )
            ),
            0,
        )
        monthly_calories = func.coalesce(
            func.sum(
                case(
                    (FoodLog.created_at >= func.date_trunc("month", func.now()), FoodLog.calories),
                    else_=0,
                )
            ),
            0,
        )
        protein_total = func.coalesce(func.sum(FoodLog.protein), 0)
        carbs_total = func.coalesce(func.sum(FoodLog.carbs), 0)
        fat_total = func.coalesce(func.sum(FoodLog.fat), 0)
        average_calories = func.coalesce(func.avg(FoodLog.calories), 0)
        total_meals = func.coalesce(func.count(), 0)

        query = select(
            today_calories.label("today_calories"),
            weekly_calories.label("weekly_calories"),
            monthly_calories.label("monthly_calories"),
            average_calories.label("average_calories"),
            protein_total.label("protein_total"),
            carbs_total.label("carbs_total"),
            fat_total.label("fat_total"),
            total_meals.label("total_meals"),
        ).where(FoodLog.user_id == user_id)

        result = await self.session.execute(query)
        row = result.one()
        return {
            "today_calories": row.today_calories,
            "weekly_calories": row.weekly_calories,
            "monthly_calories": row.monthly_calories,
            "average_calories": row.average_calories,
            "protein_total": row.protein_total,
            "carbs_total": row.carbs_total,
            "fat_total": row.fat_total,
            "total_meals": row.total_meals,
        }
