import base64
import logging
from http import HTTPStatus
from pathlib import Path
from typing import Any

from app.exceptions.base import AppException
from app.providers.ai import AIProvider
from app.schemas.ai import NutritionAnalysisResponse


logger = logging.getLogger(__name__)


class AIService:
    def __init__(self, ai_provider: AIProvider, uploads_dir: Path | None = None) -> None:
        self.ai_provider = ai_provider
        self.uploads_dir = uploads_dir or Path("uploads")

    async def analyze_food_image(
        self,
        *,
        image_url: str,
    ) -> tuple[NutritionAnalysisResponse, dict[str, Any]]:
        logger.info("AI food analysis requested for image_url=%s", image_url)
        image_data_url = self._resolve_image_data_url(image_url)
        return await self.ai_provider.analyze_food_image(image_data_url=image_data_url)

    def _resolve_image_data_url(self, image_url: str) -> str:
        if image_url.startswith("data:image/"):
            return image_url

        if not image_url.startswith("/uploads/"):
            raise AppException(
                "Only locally uploaded image URLs are supported for analysis.",
                status_code=HTTPStatus.BAD_REQUEST,
                error_code="unsupported_image_url",
            )

        filename = image_url.removeprefix("/uploads/")
        image_path = (self.uploads_dir / filename).resolve()
        uploads_root = self.uploads_dir.resolve()

        if uploads_root not in image_path.parents:
            raise AppException(
                "Invalid image URL.",
                status_code=HTTPStatus.BAD_REQUEST,
                error_code="invalid_image_url",
            )

        if not image_path.exists() or not image_path.is_file():
            raise AppException(
                "Uploaded image was not found.",
                status_code=HTTPStatus.NOT_FOUND,
                error_code="uploaded_image_not_found",
            )

        mime_type = self._mime_type_for_path(image_path)
        encoded_image = base64.b64encode(image_path.read_bytes()).decode("utf-8")
        return f"data:{mime_type};base64,{encoded_image}"

    @staticmethod
    def _mime_type_for_path(image_path: Path) -> str:
        suffix = image_path.suffix.lower()
        if suffix in {".jpg", ".jpeg"}:
            return "image/jpeg"
        if suffix == ".png":
            return "image/png"

        raise AppException(
            "Only JPG, JPEG, and PNG images can be analyzed.",
            status_code=HTTPStatus.BAD_REQUEST,
            error_code="unsupported_image_type",
        )
