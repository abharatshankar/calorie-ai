from typing import Final


class AppConstants:
    """Application-wide constants."""

    DEFAULT_PAGE_SIZE: Final[int] = 20
    MAX_PAGE_SIZE: Final[int] = 100

    MAX_IMAGE_SIZE_BYTES: Final[int] = 10 * 1024 * 1024  # 10 MB

    ALLOWED_IMAGE_CONTENT_TYPES: Final[frozenset[str]] = frozenset({"image/jpeg", "image/png"})
    ALLOWED_IMAGE_EXTENSIONS: Final[frozenset[str]] = frozenset({".jpg", ".jpeg", ".png"})
