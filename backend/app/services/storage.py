import asyncio
from abc import ABC, abstractmethod
from pathlib import Path
from uuid import uuid4

from fastapi import UploadFile


class StorageService(ABC):
    @abstractmethod
    async def save_upload(self, *, file: UploadFile, content: bytes) -> tuple[str, str]:
        """Persist an uploaded file and return its public URL plus stored filename."""


class LocalStorageService(StorageService):
    def __init__(self, upload_dir: Path | None = None) -> None:
        self.upload_dir = upload_dir or Path("uploads")

    async def save_upload(self, *, file: UploadFile, content: bytes) -> tuple[str, str]:
        extension = Path(file.filename or "").suffix.lower()
        stored_filename = f"{uuid4().hex}{extension}"
        destination = self.upload_dir / stored_filename

        # Disk I/O is blocking; keep it off the event loop.
        await asyncio.to_thread(self._write_file, destination, content)

        return f"/uploads/{stored_filename}", stored_filename

    def _write_file(self, destination: Path, content: bytes) -> None:
        self.upload_dir.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
