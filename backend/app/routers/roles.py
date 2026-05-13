from sqlalchemy.orm import Session
from app.core.database import get_db
from fastapi import APIRouter, Depends, HTTPException
from app.services.roles import create_role, list_roles, update_role, delete_role, list_role_by_user, update_user_role
from app.routers.auth import get_current_user
from app.schemas.roles import RoleCreate, RoleResponse, UserRoleUpdate
from app.models.user import User

router = APIRouter(prefix="/roles", tags=["roles"])

@router.post("/create", response_model=RoleResponse)
def create_role_endpoint(role: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return create_role(db, role.name_rol, role.description)

@router.put("/update/{role_id}", response_model=RoleResponse)
def update_role_endpoint(role_id: int, role: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return update_role(db, role_id, role.name_rol, role.description)

@router.delete("/delete/{role_id}")
def delete_role_endpoint(role_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return delete_role(db, role_id, current_user.id)

@router.get("/user/{user_id}", response_model = list[RoleResponse])
def list_role_by_user_endpoint(user_id: int, db: Session = Depends(get_db)):
    return list_role_by_user(db, user_id)

@router.get("/all", response_model = list[RoleResponse])
def list_all_roles_endpoint(db: Session = Depends(get_db)):
    return list_roles(db)

@router.put("/update-role/{user_id}")
def update_user_role_route(user_id: int, data: UserRoleUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role_id != 1:
        raise HTTPException(status_code=403, detail="No autorizado para cambiar roles")
    update_user_role(db, user_id, data.role_id)
    return {"message": "Rol actualizado exitosamente"}
