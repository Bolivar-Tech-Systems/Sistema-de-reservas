from app.models.roles import Role
from app.core.database import get_db
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

def create_role(db:Session, user_id: int, name_rol:str, description: str = None):
    role = db.query(Role).filter(Role.name_rol == name_rol).first()
    if role:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El rol ya existe"
        )
    try:
        new_role = Role(name_rol=name_rol, user_id=user_id, description=description)
        db.add(new_role)
        db.commit()
        db.refresh(new_role)
        return new_role
    except Exception as e:
            db.rollback()
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

def update_role(db:Session, role_id: int, name_rol:str, description: str = None):
    role = db.query(Role).filter(Role.id == role_id).first()
    if not role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="El rol no existe"
        )
    try:
        role.name_rol = name_rol
        role.description = description
        db.commit()
        db.refresh(role)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
        
def delete_role(db:Session, role_id: int, user_id: int):
    role = db.query(Role).filter(Role.id == role_id, Role.user_id == user_id).first()
    if not role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="El rol no existe"
        )
    try:
        db.delete(role)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

def list_role_by_user(db:Session, user_id: int):
    roles= db.query(Role).filter(Role.user_id == user_id).all()
    if not roles:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontraron roles para este usuario"
        )
    return roles

def list_roles(db:Session):
    roles = db.query(Role).all()
    if not roles:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontraron roles"
        )
    return roles