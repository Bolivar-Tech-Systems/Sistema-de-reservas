from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    password_confirmation: str

class UserLogin(BaseModel):
    email: str
    password: str
    
class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    
    class Config:
        from_attributes = True

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
    total_reservas: int
    activas: int
    favoritos: int

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[EmailStr] = None