from abc import ABC, abstractmethod
from typing import Any

from app.schemas.ai import NutritionAnalysisResponse


class AIProvider(ABC):
    @abstractmethod
    async def analyze_food_image(
        self,
        *,
        image_data_url: str,
    ) -> tuple[NutritionAnalysisResponse, dict[str, Any]]:
        """Analyze a food image and return structured nutrition estimates plus raw AI response."""
