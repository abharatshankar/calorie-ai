import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from app.exceptions.base import AppException

logger = logging.getLogger(__name__)


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(AppException)
    async def app_exception_handler(
        request: Request,
        exc: AppException,
    ) -> JSONResponse:
        logger.info(
            "Application exception: path=%s code=%s message=%s",
            request.url.path,
            exc.error_code,
            exc.message,
        )
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.message, "error_code": exc.error_code},
        )

    @app.exception_handler(HTTPException)
    async def http_exception_handler(
        request: Request,
        exc: HTTPException,
    ) -> JSONResponse:
        logger.info(
            "HTTP exception: path=%s status=%s detail=%s",
            request.url.path,
            exc.status_code,
            exc.detail,
        )
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.detail, "error_code": "http_error"},
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(
        request: Request,
        exc: RequestValidationError,
    ) -> JSONResponse:
        # Pydantic v2 error dicts embed the offending "input" (and sometimes "ctx"),
        # which would echo submitted secrets such as passwords back to the client and
        # into logs. Strip those fields before logging or returning the response.
        sanitized_errors = [
            {"type": error.get("type"), "loc": error.get("loc"), "msg": error.get("msg")}
            for error in exc.errors()
        ]
        logger.info(
            "Validation exception: path=%s errors=%s",
            request.url.path,
            sanitized_errors,
        )
        return JSONResponse(
            status_code=422,
            content={"detail": sanitized_errors, "error_code": "validation_error"},
        )

    @app.exception_handler(Exception)
    async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        logger.exception("Unhandled exception: path=%s error=%s", request.url.path, exc)
        return JSONResponse(
            status_code=500,
            content={
                "detail": "An unexpected error occurred.",
                "error_code": "internal_server_error",
            },
        )
