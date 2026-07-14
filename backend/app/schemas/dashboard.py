from pydantic import BaseModel, Field


class DashboardResponse(BaseModel):
    today_calories: int = Field(ge=0, description="Calories logged today")
    weekly_calories: int = Field(ge=0, description="Calories logged in the last 7 days")
    monthly_calories: int = Field(ge=0, description="Calories logged in the current month")
    average_calories: float = Field(ge=0, description="Average calories per meal")
    protein_total: float = Field(ge=0, description="Total protein logged")
    carbs_total: float = Field(ge=0, description="Total carbs logged")
    fat_total: float = Field(ge=0, description="Total fat logged")
    total_meals: int = Field(ge=0, description="Number of food log entries")
