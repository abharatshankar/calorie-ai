import json
import logging
from http import HTTPStatus
from typing import Any

from openai import (
    APIConnectionError,
    APITimeoutError,
    AsyncOpenAI,
    OpenAIError,
    PermissionDeniedError,
    RateLimitError,
)
from pydantic import ValidationError

from app.config.settings import settings
from app.exceptions.base import AppException
from app.providers.ai import AIProvider
from app.schemas.ai import NutritionAnalysisResponse


logger = logging.getLogger(__name__)


NUTRITION_ANALYSIS_SCHEMA = {
    "type": "object",
    "properties": {
        "detected_food_name": {
            "type": "string",
            "description": "Best detected name of the main food or meal.",
        },
        "calories": {
            "type": "integer",
            "description": "Estimated calories for the visible serving.",
            "minimum": 0,
        },
        "protein": {
            "type": "number",
            "description": "Estimated protein in grams.",
            "minimum": 0,
        },
        "carbs": {
            "type": "number",
            "description": "Estimated carbohydrates in grams.",
            "minimum": 0,
        },
        "fat": {
            "type": "number",
            "description": "Estimated fat in grams.",
            "minimum": 0,
        },
        "serving_size": {
            "type": "string",
            "description": "Estimated serving size for the visible food.",
        },
        "confidence": {
            "type": "number",
            "description": "Confidence score from 0 to 1.",
            "minimum": 0,
            "maximum": 1,
        },
        "nutrition_summary": {
            "type": "string",
            "description": "Brief human-readable summary of the nutrition estimate.",
        },
    },
    "required": [
        "detected_food_name",
        "calories",
        "protein",
        "carbs",
        "fat",
        "serving_size",
        "confidence",
        "nutrition_summary",
    ],
    "additionalProperties": False,
}


class OpenAIProvider(AIProvider):
    def __init__(self) -> None:
        if not settings.openai_api_key:
            raise AppException(
                "OpenAI API key is not configured.",
                status_code=HTTPStatus.SERVICE_UNAVAILABLE,
                error_code="openai_api_key_missing",
            )

        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_vision_model

    async def analyze_food_image(self, *, image_data_url: str) -> tuple[NutritionAnalysisResponse, dict[str, Any]]:
        try:
            logger.info(
                "Sending AI nutrition analysis request: model=%s image_data_url=%s",
                self.model,
                image_data_url[:120] if len(image_data_url) > 120 else image_data_url,
            )
            response = await self.client.responses.create(
                model=self.model,
                input=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "input_text",
                                "text": (
                                    "Analyze this food image. Estimate nutrition for the visible "
                                    "serving only. Return conservative estimates when uncertain."
                                ),
                            },
                            {
                                "type": "input_image",
                                "image_url": image_data_url,
                            },
                        ],
                    }
                ],
                text={
                    "format": {
                        "type": "json_schema",
                        "name": "nutrition_analysis",
                        "strict": True,
                        "schema": NUTRITION_ANALYSIS_SCHEMA,
                    }
                },
            )
        except (APITimeoutError, APIConnectionError) as exc:
            logger.warning("OpenAI connection failure during food analysis: %s", exc)
            raise AppException(
                "AI nutrition analysis is temporarily unavailable.",
                status_code=HTTPStatus.SERVICE_UNAVAILABLE,
                error_code="ai_provider_unavailable",
            ) from exc
        except RateLimitError as exc:
            logger.warning("OpenAI rate limit during food analysis: %s", exc)
            raise AppException(
                "AI nutrition analysis is rate limited. Please try again later.",
                status_code=HTTPStatus.TOO_MANY_REQUESTS,
                error_code="ai_provider_rate_limited",
            ) from exc
        except PermissionDeniedError as exc:
            if "quota" in str(exc).lower():
                logger.warning("OpenAI quota exceeded during food analysis: %s", exc)
                raise AppException(
                    "AI nutrition analysis quota has been exceeded.",
                    status_code=HTTPStatus.TOO_MANY_REQUESTS,
                    error_code="ai_provider_quota_exceeded",
                ) from exc
            logger.warning("OpenAI permission failure during food analysis: %s", exc)
            raise AppException(
                "AI nutrition analysis is not permitted.",
                status_code=HTTPStatus.FORBIDDEN,
                error_code="ai_provider_permission_denied",
            ) from exc
        except OpenAIError as exc:
            if "quota" in str(exc).lower():
                logger.warning("OpenAI quota exceeded during food analysis: %s", exc)
                raise AppException(
                    "AI nutrition analysis quota has been exceeded.",
                    status_code=HTTPStatus.TOO_MANY_REQUESTS,
                    error_code="ai_provider_quota_exceeded",
                ) from exc
            logger.warning("OpenAI API failure during food analysis: %s", exc)
            raise AppException(
                "AI nutrition analysis failed.",
                status_code=HTTPStatus.BAD_GATEWAY,
                error_code="ai_provider_error",
            ) from exc

        try:
            payload = json.loads(response.output_text)
            analysis = NutritionAnalysisResponse.model_validate(payload)
            return analysis, self._serialize_raw_response(response)
        except (json.JSONDecodeError, ValidationError) as exc:
            logger.warning("Invalid OpenAI nutrition analysis response: %s", exc)
            raise AppException(
                "AI nutrition analysis returned an invalid response.",
                status_code=HTTPStatus.BAD_GATEWAY,
                error_code="invalid_ai_response",
            ) from exc

    @staticmethod
    def _serialize_raw_response(response: Any) -> dict[str, Any]:
        if hasattr(response, "model_dump"):
            raw_response = response.model_dump()
        elif hasattr(response, "dict"):
            raw_response = response.dict()
        else:
            raw_response = {k: v for k, v in vars(response).items() if not k.startswith("_")}

        return json.loads(json.dumps(raw_response, default=str))
