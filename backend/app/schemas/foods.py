from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class FoodLogCreateRequest(BaseModel):
    image_url: str | None = Field(default=None, max_length=2048)
    detected_food_name: str = Field(min_length=1, max_length=255)
    calories: int = Field(ge=0)
    protein: float = Field(ge=0)
    carbs: float = Field(ge=0)
    fat: float = Field(ge=0)
    serving_size: str | None = Field(default=None, min_length=1, max_length=100)
    confidence: float | None = Field(default=None, ge=0, le=1)
    # Make nutrition_summary optional for manual creates; AI will populate when available.
    nutrition_summary: str = Field(default="", max_length=1024)
    ai_response: dict[str, Any] | None = None


class FoodLogBaseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, ser_json_by_alias=True)

    id: UUID
    food_name: str = Field(alias="detected_food_name")
    image_url: str | None
    calories: int
    protein: float
    carbs: float
    fat: float
    serving_size: str | None
    confidence: float | None
    nutrition_summary: str
    created_at: datetime


class FoodLogPublicResponse(FoodLogBaseResponse):
    """
    Public API response for food logs.
    Excludes internal details like ai_response and user_id.
    Suitable for return to API consumers.
    """

    updated_at: datetime


class FoodLogListPublicResponse(BaseModel):
    """
    Paginated public response for food history and dashboard.
    Items contain only public-safe fields without ai_response or user_id.
    """

    items: list[FoodLogPublicResponse]
    total: int
    page: int
    size: int
    pages: int

    @classmethod
    def paginate(
        cls,
        *,
        items: list[Any],
        total: int,
        page: int,
        size: int,
    ) -> "FoodLogListPublicResponse":
        pages = (total + size - 1) // size if total and size else 0
        return cls(items=items, total=total, page=page, size=size, pages=pages)
