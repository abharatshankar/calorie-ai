from hashlib import sha256
from secrets import token_urlsafe


def create_opaque_token() -> str:
    return token_urlsafe(48)


def hash_token(token: str) -> str:
    return sha256(token.encode("utf-8")).hexdigest()
