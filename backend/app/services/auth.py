from app.models.user import Role
from sqlalchemy.orm import Session 
from fastapi import HTTPException, status, Response
from passlib.context import CryptContext
from app.models.user import User
from app.models.reservas import ReservaUsuario
from app.schemas.user import UserCreate, UserLogin, UserResponse, UserProfile, UserUpdate,UpdatePasswordRequest
from app.core.security import create_access_token, verify_token
from app.core.config import  FORGET_PWD_SECRET_KEY, ALGORITHM
from jose import jwt, JWTError
from app.core.config import FORGET_PWD_SECRET_KEY, ALGORITHM
from fastapi.responses import JSONResponse
import random, string
from datetime import datetime, timedelta
from app.services.notificaciones_services import crear_notificacion
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
            new_user = User(
                nombre=user.nombre,
                email=user.email,
                password=hashed_password,
                telefono=user.telefono,
                foto_perfil=user.foto_perfil,
                role_id=user.role_id if user.role_id is not None else 2,
            )
            db.add(new_user)
            db.commit()
            db.refresh(new_user)

            # Notificación de bienvenida
            try:
                crear_notificacion(
                    id_usuario=str(new_user.id),
                    titulo="Bienvenido",
                    mensaje="Tu cuenta fue creada exitosamente",
                    tipo="bienvenida",
                )
            except Exception:
                pass

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
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "id": db_user.id,
        "name": db_user.nombre,
        "email": db_user.email,
        "role_id": db_user.role_id,
    }

def logout_user(response= Response):
    response.delete_cookie(key="access_token")
    return {"detail": "Usuario desconectado"}

def get_user_profile(current_user: User, db: Session) -> UserProfile:
    total_reservas = (
        db.query(ReservaUsuario)
        .filter(ReservaUsuario.usuario_id == current_user.id)
        .count()
    )
    activas = (
        db.query(ReservaUsuario)
        .filter(
            ReservaUsuario.usuario_id == current_user.id,
            ReservaUsuario.estado == "pendiente",
        ).count()
    )
    favoritos = 0

    return UserProfile(
        id=current_user.id,
        nombre=current_user.nombre,
        email=current_user.email,
        telefono=current_user.telefono,
        foto_perfil=current_user.foto_perfil,
        total_reservas=total_reservas,
        activas=activas,
        favoritos=favoritos,
        role_id=current_user.role_id,
    )

def update_user_profile(datos: UserUpdate, current_user: User, db: Session) -> UserProfile:
    if datos.email and datos.email != current_user.email:
        existing = db.query(User).filter(User.email == datos.email).first()
        if existing:
            raise HTTPException(status_code=400, detail="El email ya está en uso")
        current_user.email = datos.email

    if datos.nombre:
        current_user.nombre = datos.nombre

    if datos.telefono is not None:
        current_user.telefono = datos.telefono
        
    if datos.foto_perfil is not None:
        current_user.foto_perfil = datos.foto_perfil

    db.commit()
    db.refresh(current_user)
    return get_user_profile(current_user, db)

def update_user_password(data: UserUpdate, current_user: User, db: Session):
    
    if not verify_password(data.current_password, current_user.password):
        raise HTTPException(status_code=400, detail="La contraseña actual es incorrecta")
        
    hashed_password = get_password_hash(data.new_password)
    current_user.password = hashed_password
    db.commit()

    # Notificar cambio de contraseña
    try:
        crear_notificacion(
            id_usuario=str(current_user.id),
            titulo="Contraseña actualizada",
            mensaje="Tu contraseña fue cambiada exitosamente",
            tipo="seguridad",
        )
    except Exception:
        pass
    
    return {
        "success": True,
        "status_code": 200,
        "message": "Contraseña actualizada exitosamente"
    }

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

def get_all_users(db: Session):
    return db.query(User).all()
    
def delete_user(user_id: int, db: Session):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    db.delete(user)
    db.commit()
    return {"message": "Usuario eliminado correctamente"}


def verify_google_id_token(id_token: str) -> dict:
    import urllib.request
    import json
    url = f"https://oauth2.googleapis.com/tokeninfo?id_token={id_token}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            if "error_description" in data:
                raise ValueError(data["error_description"])
            return data
    except Exception as e:
        raise ValueError(f"Error al validar el token de Google: {e}")



def login_or_register_social_user(db: Session, email: str, name: str, profile_pic: str | None = None, phone: str | None = None):
    db_user = db.query(User).filter(User.email == email).first()
    if not db_user:
        try:
            db_user = User(
                nombre=name or email.split("@")[0],
                email=email,
                password=None,
                foto_perfil=profile_pic,
                telefono=phone,
                role_id=2,
            )
            db.add(db_user)
            db.commit()
            db.refresh(db_user)
            
            try:
                crear_notificacion(
                    id_usuario=str(db_user.id),
                    titulo="Bienvenido",
                    mensaje="Tu cuenta fue creada exitosamente vía Login Social",
                    tipo="bienvenida",
                )
            except Exception:
                pass
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=f"Error al registrar usuario social: {str(e)}")
    else:
        # Si el usuario ya existe pero no tiene foto o teléfono, los actualizamos
        updated = False
        if not db_user.foto_perfil and profile_pic:
            db_user.foto_perfil = profile_pic
            updated = True
        if not db_user.telefono and phone:
            db_user.telefono = phone
            updated = True
        if updated:
            try:
                db.commit()
                db.refresh(db_user)
            except Exception:
                db.rollback()
            
    access_token = create_access_token(data={"sub": db_user.email})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "id": db_user.id,
        "name": db_user.nombre,
        "email": db_user.email,
        "role_id": db_user.role_id,
        "foto_perfil": db_user.foto_perfil,
        "telefono": db_user.telefono,
    }

