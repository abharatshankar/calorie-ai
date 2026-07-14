from http import HTTPStatus

from fastapi import APIRouter, Depends, File, UploadFile, status

from app.api.dependencies.auth import get_current_user
from app.api.dependencies.uploads import (
    get_storage_service,
    validate_upload_metadata,
    validate_upload_size,
)
from app.models.user import User
from app.schemas.uploads import UploadResponse
from app.services.storage import StorageService

router = APIRouter(prefix="/upload")


@router.post(
    "",
    response_model=UploadResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload a food image",
    responses={
        HTTPStatus.BAD_REQUEST: {"description": "Invalid image upload"},
        HTTPStatus.UNAUTHORIZED: {"description": "Invalid or missing token"},
        status.HTTP_413_CONTENT_TOO_LARGE: {"description": "Image exceeds maximum size"},
    },
)
async def upload_image(
    file: UploadFile = File(..., description="JPEG or PNG image, maximum 10MB"),
    current_user: User = Depends(get_current_user),
    storage_service: StorageService = Depends(get_storage_service),
) -> UploadResponse:
    validate_upload_metadata(file)
    content = await file.read()
    validate_upload_size(content)

    image_url, filename = await storage_service.save_upload(file=file, content=content)
    return UploadResponse(
        image_url=image_url,
        filename=filename,
        size=len(content),
    )
