import logging
from http import HTTPStatus
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions.base import AppException
from app.models.food_log import FoodLog
from app.repositories.food_logs import FoodLogRepository
from app.schemas.foods import FoodLogCreateRequest, FoodLogListResponse

logger = logging.getLogger(__name__)


class FoodLogService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session
        self.food_logs = FoodLogRepository(session)

    async def create(self, *, user_id: UUID, payload: FoodLogCreateRequest) -> FoodLog:
        try:
            logger.debug("Creating food log payload=%s", payload.model_dump())
            food_log = await self.food_logs.create(user_id=user_id, payload=payload)
            await self.session.commit()
            logger.info("Food log created: food_log_id=%s user_id=%s", food_log.id, user_id)
            return food_log
        except Exception as exc:
            # Log and raise a controlled application exception for upstream visibility
            logger.exception("Failed to create food log: user_id=%s error=%s", user_id, exc)
            raise AppException(
                "Failed to save food log.",
                status_code=HTTPStatus.INTERNAL_SERVER_ERROR,
                error_code="db_error",
            ) from exc

    async def list_for_user(
        self,
        *,
        user_id: UUID,
        page: int,
        size: int,
        search: str | None,
    ) -> FoodLogListResponse:
        total = await self.food_logs.count_by_user(user_id=user_id, search=search)
        items = await self.food_logs.list_by_user(
            user_id=user_id,
            page=page,
            size=size,
            search=search,
        )
        pages = (total + size - 1) // size if total else 0

        return FoodLogListResponse(
            items=items,
            total=total,
            page=page,
            size=size,
            pages=pages,
        )

    async def get_for_user(self, *, food_log_id: UUID, user_id: UUID) -> FoodLog:
        food_log = await self.food_logs.get_by_id_for_user(
            food_log_id=food_log_id,
            user_id=user_id,
        )
        if food_log is None:
            raise AppException(
                "Food log was not found.",
                status_code=HTTPStatus.NOT_FOUND,
                error_code="food_log_not_found",
            )
        return food_log

    async def create_if_not_exists(
        self,
        *,
        user_id: UUID,
        payload: FoodLogCreateRequest,
    ) -> tuple[FoodLog, bool]:
        if payload.image_url:
            existing = await self.food_logs.get_by_user_image_url(
                user_id=user_id,
                image_url=payload.image_url,
            )
            if existing:
                logger.info(
                    "Duplicate food log detected; returning existing entry: "
                    "user_id=%s image_url=%s",
                    user_id,
                    payload.image_url,
                )
                return existing, False

        food_log = await self.create(user_id=user_id, payload=payload)
        return food_log, True

    async def delete_for_user(self, *, food_log_id: UUID, user_id: UUID) -> None:
        deleted = await self.food_logs.delete_by_id_for_user(
            food_log_id=food_log_id,
            user_id=user_id,
        )
        if not deleted:
            raise AppException(
                "Food log was not found.",
                status_code=HTTPStatus.NOT_FOUND,
                error_code="food_log_not_found",
            )

        await self.session.commit()
        logger.info("Food log deleted: food_log_id=%s user_id=%s", food_log_id, user_id)
