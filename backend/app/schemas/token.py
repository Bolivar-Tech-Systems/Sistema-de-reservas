from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str
    id: int | None = None
    name: str | None = None
    email: str | None = None
    role_id: int | None = None

class GoogleToken(Token):
    foto_perfil: str | None = None
    telefono: str | None = None

class TokenData(BaseModel):
    email: str | None = None