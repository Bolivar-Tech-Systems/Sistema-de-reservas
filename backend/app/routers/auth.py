from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse, ForgetPasswordRequest, ResetForgottenPassword, SuccessMessage, UserProfile, UserUpdate
from app.schemas.token import Token
from app.services.auth import create_user, login_user, logout_user, get_user_profile, update_user_profile
from app.core.security import verify_token
from fastapi_mail import FastMail, MessageSchema, MessageType
from jose import jwt
from starlette.background import BackgroundTasks
from app.core.config import FORGET_PWD_SECRET_KEY, ALGORITHM
from datetime import datetime, timedelta
from app.core.mail import mail_conf
from app.services.auth import generate_forget_password_email, reset_user_password



router = APIRouter(prefix="/auth", tags=["auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    email = verify_token(token)
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user

@router.post("/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    return create_user(db, user)

@router.post("/login", response_model=Token)
def login(user: UserLogin, db: Session = Depends(get_db)):
    return login_user(db, user)

@router.post("/logout")
def logout(current_user: User = Depends(get_current_user)):
        return logout_user

@router.get("/me/", response_model=UserProfile)
def get_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db),):
     return get_user_profile(current_user, db)

@router.patch("/me/", response_model=UserProfile)
def update_profile(datos: UserUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db),):
     return update_user_profile(datos, current_user, db)

@router.post("/forget-password")
async def forget_password(
     background_tasks: BackgroundTasks,
     fpr: ForgetPasswordRequest,
     db: Session = Depends(get_db)
):
     try:

          email_body = generate_forget_password_email(
               email=fpr.email,
               db=db
          )
          message = MessageSchema(
               subject="Instrucciones para el reseteo de contraseña",
               recipients=[fpr.email],
               template_body=email_body,
               subtype=MessageType.html
          )
          template_name = "mail/password_reset.html"
          fm = FastMail(mail_conf)
          background_tasks.add_task(fm.send_message, message, template_name=template_name)

          return  {"message": "Se ha enviado el email", "completado": True,}    
     except HTTPException:
          raise
     except Exception:
          raise HTTPException(status_code=500, detail="Algo inesperado sucedio, error del servidor")
                              
@router.post("/reset-password", response_model=SuccessMessage)
async def reset_password(
     rfp: ResetForgottenPassword,
     db: Session = Depends(get_db)
):
     return reset_user_password(rfp,db)

