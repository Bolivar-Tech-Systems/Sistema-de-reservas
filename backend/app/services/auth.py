from sqlalchemy.orm import Session
from fastapi import HTTPException, status, Response
from passlib.context import CryptContext
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse
from app.core.security import create_access_token, verify_token
from fastapi.responses import JSONResponse

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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
            new_user = User(name=user.name, email=user.email, password=hashed_password, role="user")
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

def logout_user():
    return JSONResponse({"message": "Logout exitoso"}, status_code=status.HTTP_200_OK)