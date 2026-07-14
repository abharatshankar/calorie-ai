from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import defer

from app.models.food_log import FoodLog
from app.schemas.foods import FoodLogCreateRequest


class FoodLogRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, *, user_id: UUID, payload: FoodLogCreateRequest) -> FoodLog:
        food_log = FoodLog(user_id=user_id, **payload.model_dump())
        self.session.add(food_log)
        await self.session.flush()
        await self.session.refresh(food_log)
        return food_log

    async def list_by_user(
        self,
        *,
        user_id: UUID,
        page: int,
        size: int,
        search: str | None,
    ) -> list[FoodLog]:
        # ai_response (large JSONB) is never returned by list endpoints; defer it
        # so it is not fetched, transferred, or materialized for every row.
        query = (
            select(FoodLog).where(FoodLog.user_id == user_id).options(defer(FoodLog.ai_response))
        )
        if search:
            query = query.where(FoodLog.detected_food_name.ilike(f"%{search}%"))

        result = await self.session.execute(
            query.order_by(FoodLog.created_at.desc()).offset((page - 1) * size).limit(size)
        )
        return list(result.scalars().all())

    async def count_by_user(self, *, user_id: UUID, search: str | None) -> int:
        query = select(func.count()).select_from(FoodLog).where(FoodLog.user_id == user_id)
        if search:
            query = query.where(FoodLog.detected_food_name.ilike(f"%{search}%"))

        result = await self.session.execute(query)
        return result.scalar_one()

    async def get_by_id_for_user(self, *, food_log_id: UUID, user_id: UUID) -> FoodLog | None:
        result = await self.session.execute(
            select(FoodLog)
            .where(
                FoodLog.id == food_log_id,
                FoodLog.user_id == user_id,
            )
            .options(defer(FoodLog.ai_response))
        )
        return result.scalar_one_or_none()

    async def get_by_user_image_url(self, *, user_id: UUID, image_url: str) -> FoodLog | None:
        result = await self.session.execute(
            select(FoodLog).where(
                FoodLog.user_id == user_id,
                FoodLog.image_url == image_url,
            )
        )
        return result.scalar_one_or_none()

    async def delete_by_id_for_user(self, *, food_log_id: UUID, user_id: UUID) -> bool:
        result = await self.session.execute(
            delete(FoodLog).where(
                FoodLog.id == food_log_id,
                FoodLog.user_id == user_id,
            )
        )
        return result.rowcount > 0
