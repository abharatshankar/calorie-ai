from http import HTTPStatus

from fastapi import UploadFile, status

from app.config.constants import AppConstants
from app.exceptions.base import AppException
from app.services.storage import LocalStorageService, StorageService


def get_storage_service() -> StorageService:
    return LocalStorageService()


def validate_upload_metadata(file: UploadFile) -> None:
    if file.content_type not in AppConstants.ALLOWED_IMAGE_CONTENT_TYPES:
        raise AppException(
            "Only JPG, JPEG, and PNG images are allowed.",
            status_code=HTTPStatus.BAD_REQUEST,
            error_code="unsupported_image_type",
        )

    filename = (file.filename or "").lower()
    if not any(filename.endswith(extension) for extension in AppConstants.ALLOWED_IMAGE_EXTENSIONS):
        raise AppException(
            "Image filename must end with .jpg, .jpeg, or .png.",
            status_code=HTTPStatus.BAD_REQUEST,
            error_code="unsupported_image_extension",
        )

    # Reject oversized uploads up front (from the multipart part size) so we
    # never buffer a huge body into memory just to reject it afterwards.
    if file.size is not None and file.size > AppConstants.MAX_IMAGE_SIZE_BYTES:
        raise AppException(
            "Image size must not exceed 10MB.",
            status_code=status.HTTP_413_CONTENT_TOO_LARGE,
            error_code="image_too_large",
        )


def validate_upload_size(content: bytes) -> None:
    if not content:
        raise AppException(
            "Uploaded image must not be empty.",
            status_code=HTTPStatus.BAD_REQUEST,
            error_code="empty_image",
        )

    if len(content) > AppConstants.MAX_IMAGE_SIZE_BYTES:
        raise AppException(
            "Image size must not exceed 10MB.",
            status_code=status.HTTP_413_CONTENT_TOO_LARGE,
            error_code="image_too_large",
        )
