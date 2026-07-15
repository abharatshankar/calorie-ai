from contextlib import asynccontextmanager
from pathlib import Path
import logging

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from app.api.v1.router import api_router
from app.config.settings import settings
from app.core.logging import configure_logging
from app.exceptions.handlers import register_exception_handlers


configure_logging()
logger = logging.getLogger(__name__)

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application startup and shutdown lifecycle.
    """

    logger.info("🚀 Starting Calorie AI...")
    yield
    logger.info("🛑 Shutting down Calorie AI...")


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description=settings.app_description,
    lifespan=lifespan,
)

register_exception_handlers(app)
app.include_router(api_router, prefix="/api/v1")
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")
