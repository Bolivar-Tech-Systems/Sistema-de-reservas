from sqlalchemy.orm import Session
from app.models.roles import Role
from app.core.database import get_db
from fastapi import APIRouter, Depends, HTTPException, status
from app.services.roles import create_role, list_roles, update_role, delete_role, list_role_by_user
from app.routers.auth import get_current_user
from app.schemas.roles import RoleCreate, RoleResponse
from app.services.permisos import list_permisos_by_role

router = APIRouter(prefix="/roles", tags=["roles"])

@router.post("/create", response_model=RoleCreate)
def create_role_endpoint(role: RoleCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return create_role(db, current_user.id, role.name_rol, role.description)

@router.put("/update/{role_id}", response_model=list[RoleResponse])
def update_role_endpoint(role_id: int, role: RoleCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return update_role(db, role_id, role.name_rol, role.description)

@router.delete("/delete/{role_id}")
def delete_role_endpoint(role_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return delete_role(db, role_id, current_user.id)

@router.get("/user/{user_id}", response_model = list[RoleResponse])
def list_role_by_user_endpoint(current_user: int = Depends(get_current_user), db: Session = Depends(get_db)):
    return list_role_by_user(current_user.id, db)

@router.get("/all", response_model = list[RoleResponse])
def list_all_roles_endpoint(db: Session = Depends(get_db)):
    return list_roles(db)
