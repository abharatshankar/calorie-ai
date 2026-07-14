from uuid import uuid4

import jwt
import pytest

from app.security.jwt import create_access_token, decode_token
from app.security.password import hash_password, verify_password


def test_password_hash_roundtrip() -> None:
    hashed = hash_password("correct horse battery staple")

    assert hashed != "correct horse battery staple"
    assert verify_password("correct horse battery staple", hashed) is True
    assert verify_password("wrong password", hashed) is False


def test_password_hash_is_salted() -> None:
    # Two hashes of the same password must differ (unique salt per hash).
    assert hash_password("same-password") != hash_password("same-password")


def test_access_token_roundtrip() -> None:
    user_id = uuid4()

    token = create_access_token(user_id)
    payload = decode_token(token)

    assert payload["sub"] == str(user_id)
    assert payload["type"] == "access"
    assert "exp" in payload and "iat" in payload


def test_decode_rejects_tampered_token() -> None:
    token = create_access_token(uuid4())
    tampered = token[:-2] + ("aa" if not token.endswith("aa") else "bb")

    with pytest.raises(jwt.PyJWTError):
        decode_token(tampered)
