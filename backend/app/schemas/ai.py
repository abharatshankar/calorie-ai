from pydantic import BaseModel, Field


class NutritionAnalysisRequest(BaseModel):
    image_url: str = Field(min_length=1, max_length=2048)


class NutritionAnalysisResponse(BaseModel):
    detected_food_name: str
    calories: int = Field(ge=0)
    protein: float = Field(ge=0)
    carbs: float = Field(ge=0)
    fat: float = Field(ge=0)
    serving_size: str
    confidence: float = Field(ge=0, le=1)
    nutrition_summary: str
