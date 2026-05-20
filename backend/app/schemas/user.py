from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class UserBase(BaseModel):
    nombre: str = Field(alias="name")
    email: str
    telefono: str | None = None
    foto_perfil: str | None = None
    role_id: int | None = None

    model_config = ConfigDict(populate_by_name=True)

    @property
    def name(self) -> str:
        return self.nombre


class UserCreate(UserBase):
    password: str
    password_confirmation: str


class UserLogin(BaseModel):
    email: str
    password: str


class UserResponse(UserBase):
    id: int
    created_at: datetime | None = None
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class ForgetPasswordRequest(BaseModel):
    email: str


class ResetForgottenPassword(BaseModel):
    email: str
    code: str
    new_password: str
    confirm_password: str


class SuccessMessage(BaseModel):
    success: bool
    status_code: int
    message: str


class UserProfile(BaseModel):
    id: int
    nombre: str
    email: str
    telefono: Optional[str] = None
    foto_perfil: Optional[str] = None
    fecha_registro: Optional[str] = None
    total_reservas: int
    activas: int
    favoritos: int
    role_id: int

    model_config = ConfigDict(from_attributes=True)

    @property
    def name(self) -> str:
        return self.nombre


class UserUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[str] = None
    telefono: Optional[str] = None
    foto_perfil: Optional[str] = None

class UpdatePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class GoogleLoginRequest(BaseModel):
    id_token: str


