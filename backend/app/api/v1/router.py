from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.v1.foods import router as foods_router
from app.api.v1.health import router as health_router
from app.api.v1.history import router as history_router
from app.api.v1.uploads import router as uploads_router

api_router = APIRouter()
api_router.include_router(auth_router, tags=["Authentication"])
api_router.include_router(foods_router, tags=["Foods"])
api_router.include_router(history_router, tags=["History"])
api_router.include_router(dashboard_router, tags=["Dashboard"])
api_router.include_router(health_router, tags=["Health"])
api_router.include_router(uploads_router, tags=["Uploads"])
