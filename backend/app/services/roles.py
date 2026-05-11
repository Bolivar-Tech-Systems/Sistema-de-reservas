from app.models.user import Role, User
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

def create_role(db:Session, name_rol:str, description: str = ""):
    role = db.query(Role).filter(Role.name_rol == name_rol).first()
    if role:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El rol ya existe"
        )
    try:
        new_role = Role(name_rol=name_rol, description=description)
        db.add(new_role)
        db.commit()
        db.refresh(new_role)
        return new_role
    except Exception as e:
            db.rollback()
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

def update_role(db:Session, role_id: int, name_rol:str, description: str = ""):
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
        return role
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
        
def delete_role(db:Session, role_id: int, user_id: int):
    role = db.query(Role).filter(Role.id == role_id).first()
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
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontraron roles para este usuario"
        )
    return db.query(Role).filter(Role.id == user.role_id).all()

def list_roles(db:Session):
    roles = db.query(Role).all()
    if not roles:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontraron roles"
        )
    return roles
