import time
from collections import defaultdict, deque
from http import HTTPStatus
from threading import Lock

from fastapi import Request

from app.exceptions.base import AppException


class SlidingWindowRateLimiter:
    """Process-local sliding-window rate limiter.

    Intended for abuse mitigation on sensitive endpoints (login, register,
    refresh). It is per-process only; a multi-worker or multi-instance
    deployment should place a shared store (e.g. Redis) behind this instead.
    """

    def __init__(self, *, max_requests: int, window_seconds: int) -> None:
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._hits: dict[str, deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def check(self, key: str) -> None:
        now = time.monotonic()
        window_start = now - self.window_seconds
        with self._lock:
            hits = self._hits[key]
            while hits and hits[0] < window_start:
                hits.popleft()
            if len(hits) >= self.max_requests:
                raise AppException(
                    "Too many requests. Please slow down and try again later.",
                    status_code=HTTPStatus.TOO_MANY_REQUESTS,
                    error_code="rate_limited",
                )
            hits.append(now)


def _client_ip(request: Request) -> str:
    # Trust the platform's proxy header only if present; fall back to the peer.
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


class RateLimit:
    """FastAPI dependency that rate-limits by client IP and route."""

    def __init__(self, *, max_requests: int, window_seconds: int) -> None:
        self._limiter = SlidingWindowRateLimiter(
            max_requests=max_requests,
            window_seconds=window_seconds,
        )

    async def __call__(self, request: Request) -> None:
        key = f"{request.scope['path']}:{_client_ip(request)}"
        self._limiter.check(key)


# Auth endpoints are brute-force targets, so they get a tight budget.
auth_rate_limit = RateLimit(max_requests=10, window_seconds=60)
