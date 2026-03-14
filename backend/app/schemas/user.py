from pydantic import BaseModel

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
    secret_token: str
    new_password: str
    confirm_password: str

class SuccessMessage(BaseModel):
    success: bool
    status_code: int
    message: str