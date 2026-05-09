from sqlalchemy.orm import Session 
from fastapi import HTTPException, status, Response
from passlib.context import CryptContext
from app.models.user import User
from app.models.reservas import ReservaUsuario
from app.schemas.user import UserCreate, UserLogin, UserResponse, UserProfile, UserUpdate
from app.core.security import create_access_token, verify_token
from app.core.config import  FORGET_PWD_SECRET_KEY, ALGORITHM
from jose import jwt, JWTError
from app.core.config import FORGET_PWD_SECRET_KEY, ALGORITHM
from fastapi.responses import JSONResponse
import random, string
from datetime import datetime, timedelta
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
            new_user = User(name=user.name, email=user.email, password=hashed_password,)
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

def get_user_profile(current_user: User, db: Session) -> UserProfile:
    total_reservas = (
        db.query(ReservaUsuario)
        .filter(ReservaUsuario.user_id == current_user.id)
        .count()
    )
    activas = (
        db.query(ReservaUsuario)
        .filter(
            ReservaUsuario.user_id == current_user.id,
            ReservaUsuario.estado == "pendiente",
        ).count()
    )
    favoritos = 0

    return UserProfile(
        id=current_user.id,
        nombre=current_user.name,
        email=current_user.email,
        total_reservas=total_reservas,
        activas=activas,
        favoritos=favoritos,
    )

def update_user_profile(datos: UserUpdate, current_user: User, db: Session) -> UserProfile:
    if datos.email and datos.email != current_user.email:
        existing = db.query(User).filter(User.email == datos.email).first()
        if existing:
            raise HTTPException(status_code=400, detail="El email ya está en uso")
        current_user.email = datos.email

    if datos.nombre:
        current_user.name = datos.nombre

    db.commit()
    db.refresh(current_user)
    return get_user_profile(current_user, db)

def decode_reset_password_token(token: str):
    try:
        payload = jwt.decode(token, FORGET_PWD_SECRET_KEY,
                             algorithms=[ALGORITHM])
        email = payload.get("sub")
        return email
    except JWTError:
        return None

def generate_reset_code():
    return ''.join(random.choices(string.digits, k=6))

def generate_forget_password_email(email: str, db: Session):
    user = get_user(email=email, db=db)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Correo inválido"
        )

    code = generate_reset_code()
    expire = datetime.utcnow() + timedelta(minutes=10)

    user.reset_code = code
    user.reset_code_expire = expire
    db.commit()

    email_body = {
        "code": code,
        "expire": "10 minutos"
    }

    return email_body

def reset_user_password(rfp, db: Session):

    user = get_user(email=rfp.email, db=db)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    if user.reset_code != rfp.code:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Código incorrecto"
        )

    if user.reset_code_expire < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Código expirado"
        )

    if rfp.new_password != rfp.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Las contraseñas no coinciden"
        )

    hashed_password = pwd_context.hash(rfp.new_password)

    try:
        user.password = hashed_password
        user.reset_code = None
        user.reset_code_expire = None
        db.add(user)
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Error al actualizar la contraseña")

    return {
        "success": True,
        "status_code": status.HTTP_200_OK,
        "message": "Contraseña reiniciada correctamente"
    }

def logout_user():
    return JSONResponse({"message": "Logout exitoso"}, status_code=status.HTTP_200_OK)