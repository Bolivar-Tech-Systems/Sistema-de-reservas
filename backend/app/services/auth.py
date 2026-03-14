from sqlalchemy.orm import Session
from fastapi import HTTPException, status, Response
from passlib.context import CryptContext
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse
from app.core.security import create_access_token, verify_token
from app.core.config import APP_HOST, FORGET_PASSWORD_URL, MAIL_FROM_NAME, FORGET_PASSWORD_LINK_EXPIRE_MINUTES, FORGET_PWD_SECRET_KEY, ALGORITHM
from jose import jwt, JWTError
from app.core.config import FORGET_PWD_SECRET_KEY, ALGORITHM, APP_HOST
from app.core.security import create_reset_password_token

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user(email:str, db:Session):
    return db.query(User).filter(User.email==email).first()

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_user(db: Session, user: UserCreate):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email ya registrado")
    if user.password == user.password_confirmation:
        try:
            hashed_password = get_password_hash(user.password)
            new_user = User(name=user.name, email=user.email, password=hashed_password)
            db.add(new_user)
            db.commit()
            db.refresh(new_user) 
            return new_user
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Las contraseñas no coinciden")

def login_user(db: Session, user: UserLogin):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Usuario no encontrado")
    
    if not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Contraseña incorrecta")
    
    access_token = create_access_token(data={"sub": db_user.email})
    return {"access_token": access_token, "token_type": "bearer", "id": db_user.id,"name": db_user.name, "email": db_user.email}  

def logout_user(response= Response):
    response.delete_cookie(key="access_token")
    return {"detail": "Usuario desconectado"}

def decode_reset_password_token(token: str):
    try:
        payload = jwt.decode(token, FORGET_PWD_SECRET_KEY,
                             algorithms=[ALGORITHM])
        email = payload.get("sub")
        return email
    except JWTError:
        return None
    
def generate_forget_password_email(email: str, db= Session):
    user = get_user(email=email, db=db)

    if user is None:
               raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                   detail="Correo invalido")
    secret_token = create_reset_password_token(email=user.email)

    forget_url_link = f"{APP_HOST}{FORGET_PASSWORD_URL}/{secret_token}"

    email_body = {
               "company_name": MAIL_FROM_NAME,
               "link_expire_min": FORGET_PASSWORD_LINK_EXPIRE_MINUTES,
               "reset_link": forget_url_link
          }
    return email_body

def reset_user_password(rfp, db=Session):

    info= decode_reset_password_token(token=rfp.secret_token)

    if info is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Informacion para el reinicio de la contraseña no encontrada o link expirado"
        )
    if rfp.new_password != rfp.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Las contraseñas no coinciden"
        )
    user = get_user(email=info, db=db)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    hashed_password = pwd_context.hash(rfp.new_password)
    user.password = hashed_password
    db.add(user)
    db.commit()

    return {
        "success": True,
        "status_code": status.HTTP_200_OK,
        "message": "Contraseña reiniciada correctamente"
    }
