from app.models.permisos import Permiso, PermisoRole
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.roles import Role
from app.models.user import User

def create_permiso(db: Session, name_permiso: str, description: str = None):
    permiso = db.query(Permiso).filter(Permiso.name_permiso == name_permiso).first()
    if permiso:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Permiso already exists")
    new_permiso = Permiso(name_permiso=name_permiso, description=description)
    db.add(new_permiso)
    db.commit()
    db.refresh(new_permiso)
    return new_permiso

def update_permiso(db: Session, name_permiso: str, permiso_id: int, description: str = None,):
    permiso = db.query(Permiso).filter(Permiso.name_permiso == name_permiso, Permiso.id == permiso_id).first()
    if not permiso:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Permiso not found")
    try:
        permiso.name_permiso = name_permiso
        permiso.description = description
        db.commit()
        db.refresh(permiso)
        return permiso
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error updating permiso")

def delete_permiso(db: Session, permiso_id: int):
    permiso = db.query(Permiso).filter(Permiso.id == permiso_id).first()
    if not permiso:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Permiso not found")
    try:
        db.delete(permiso)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error deleting permiso")


def list_all_permisos(db: Session):
    permisos = db.query(Permiso).all()
    if not permisos:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No permisos found")
    return permisos

def list_all_permisos_by_user(db: Session, user_id: int):
    permisos = db.query(Permiso).join(PermisoRole).join(Role).join(User).filter(User.id == user_id).all()
    if not permisos:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No permisos found for this user")
    return permisos

def assing_permiso_to_role(db: Session, permiso_id: int, role_id: int):
    permiso = db.query(Permiso).filter(Permiso.id == permiso_id).first()
    role = db.query(Role).filter(Role.id == role_id).first()
    if not permiso or not role:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Permiso or role not found")
    try:
        permiso_role = PermisoRole(permiso_id=permiso_id, role_id=role_id)
        db.add(permiso_role)
        db.commit()
        db.refresh(permiso_role)
        return permiso_role
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error assigning permiso to role")

def list_permisos_by_role(db: Session, role_id: int):
    permisos = db.query(Permiso).join(PermisoRole).filter(PermisoRole.role_id == role_id).all()
    if not permisos:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No permisos found for this role")
    return permisos