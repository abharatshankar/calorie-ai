from pydantic import BaseModel


class UploadResponse(BaseModel):
    image_url: str
    filename: str
    size: int
