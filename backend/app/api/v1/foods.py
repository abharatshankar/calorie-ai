from http import HTTPStatus
from uuid import UUID

from fastapi import APIRouter, Depends, File, Query, Response, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.api.v1.uploads import get_storage_service, validate_upload_metadata, validate_upload_size
from app.db.session import get_db_session
from app.models.food_log import FoodLog
from app.models.user import User
from app.providers.openai_provider import OpenAIProvider
from app.schemas.foods import (
    FoodLogCreateRequest,
    FoodLogListPublicResponse,
    FoodLogPublicResponse,
)
from app.services.ai import AIService
from app.services.foods import FoodLogService
from app.services.storage import StorageService

router = APIRouter(prefix="/foods")


def get_food_log_service(
    session: AsyncSession = Depends(get_db_session),
) -> FoodLogService:
    return FoodLogService(session)


def get_ai_service() -> AIService:
    return AIService(ai_provider=OpenAIProvider())


@router.post(
    "",
    response_model=FoodLogPublicResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a food log",
)
async def create_food_log(
    payload: FoodLogCreateRequest,
    current_user: User = Depends(get_current_user),
    food_log_service: FoodLogService = Depends(get_food_log_service),
) -> FoodLog:
    return await food_log_service.create(user_id=current_user.id, payload=payload)


@router.get(
    "",
    response_model=FoodLogListPublicResponse,
    summary="List food logs for the authenticated user",
    description=(
        "Returns the authenticated user's food logs sorted by latest first. Supports "
        "pagination and case-insensitive search by detected food name."
    ),
)
async def list_food_logs(
    page: int = Query(default=1, ge=1, description="Page number starting from 1"),
    size: int = Query(default=20, ge=1, le=100, description="Number of items per page"),
    search: str | None = Query(
        default=None,
        min_length=1,
        max_length=255,
        description="Search by detected food name",
    ),
    current_user: User = Depends(get_current_user),
    food_log_service: FoodLogService = Depends(get_food_log_service),
) -> FoodLogListPublicResponse:
    return await food_log_service.list_for_user(
        user_id=current_user.id,
        page=page,
        size=size,
        search=search,
    )


@router.post(
    "/analyze",
    response_model=FoodLogPublicResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Analyze a food image with AI and save the food log",
    description=(
        "Uploads a food image, analyzes it with OpenAI Vision, and returns the food log "
        "entry. Raw AI response is stored but not exposed to clients."
    ),
    responses={
        HTTPStatus.BAD_REQUEST: {"description": "Invalid image upload or unsupported image"},
        HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"},
        HTTPStatus.SERVICE_UNAVAILABLE: {
            "description": "AI provider unavailable or not configured"
        },
        HTTPStatus.BAD_GATEWAY: {"description": "AI provider returned an invalid response"},
        HTTPStatus.TOO_MANY_REQUESTS: {"description": "AI provider rate limited or quota exceeded"},
    },
)
async def analyze_food_image(
    response: Response,
    file: UploadFile = File(..., description="JPEG or PNG image, maximum 10MB"),
    current_user: User = Depends(get_current_user),
    storage_service: StorageService = Depends(get_storage_service),
    ai_service: AIService = Depends(get_ai_service),
    food_log_service: FoodLogService = Depends(get_food_log_service),
) -> FoodLog:
    validate_upload_metadata(file)
    content = await file.read()
    validate_upload_size(content)

    image_url, _ = await storage_service.save_upload(file=file, content=content)
    analysis, raw_ai_response = await ai_service.analyze_food_image(image_url=image_url)

    payload = FoodLogCreateRequest(
        image_url=image_url,
        detected_food_name=analysis.detected_food_name,
        calories=analysis.calories,
        protein=analysis.protein,
        carbs=analysis.carbs,
        fat=analysis.fat,
        serving_size=analysis.serving_size,
        confidence=analysis.confidence,
        nutrition_summary=analysis.nutrition_summary,
        ai_response=raw_ai_response,
    )

    food_log, created = await food_log_service.create_if_not_exists(
        user_id=current_user.id,
        payload=payload,
    )

    if not created:
        response.status_code = status.HTTP_200_OK

    return food_log


@router.get(
    "/{id}",
    response_model=FoodLogPublicResponse,
    summary="Get a food log by ID",
    responses={HTTPStatus.NOT_FOUND: {"description": "Food log not found"}},
)
async def get_food_log(
    id: UUID,
    current_user: User = Depends(get_current_user),
    food_log_service: FoodLogService = Depends(get_food_log_service),
) -> FoodLog:
    return await food_log_service.get_for_user(
        food_log_id=id,
        user_id=current_user.id,
    )


@router.delete(
    "/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a food log by ID",
    responses={HTTPStatus.NOT_FOUND: {"description": "Food log not found"}},
)
async def delete_food_log(
    id: UUID,
    current_user: User = Depends(get_current_user),
    food_log_service: FoodLogService = Depends(get_food_log_service),
) -> Response:
    await food_log_service.delete_for_user(
        food_log_id=id,
        user_id=current_user.id,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
