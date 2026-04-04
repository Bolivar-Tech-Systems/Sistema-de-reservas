from sqlalchemy.orm import Session
from app.models.permisos import Permiso, PermisoRole
from app.core.database import get_db
from fastapi import APIRouter, Depends, HTTPException, status
from app.services.permisos import assing_permiso_to_role, create_permiso, list_all_permisos, list_all_permisos_by_user, update_permiso, delete_permiso, list_permisos_by_role
from app.routers.auth import get_current_user
from app.schemas.permisos import PermisoCreate, PermisoResponse, PermisoRoleAssing, PermisoRoleResponse

router = APIRouter(prefix="/permisos", tags=["permisos"])

@router.post("/create", response_model=PermisoResponse)
def create_permiso_endpoint(permiso: PermisoCreate, db: Session = Depends(get_db)):
    return create_permiso(db, permiso.name_permiso, permiso.description)

@router.put("/update/{permiso_id}", response_model=PermisoResponse)
def update_permiso_endpoint(permiso_id: int, permiso: PermisoCreate, db: Session = Depends(get_db)):
    return update_permiso(db, permiso.name_permiso, permiso_id, permiso.description)

@router.get("/all", response_model=list[PermisoResponse])
def get_permiso_endpoint(db: Session = Depends(get_db)):
    return list_all_permisos(db)

@router.delete("/delete/{permiso_id}")
def delete_permiso_endpoint(permiso_id: int, db: Session = Depends(get_db)):
    return delete_permiso(db, permiso_id)

@router.get("/user/{user_id}", response_model=list[PermisoResponse])
def list_permisos_by_user_endpoint(user_id: int, db: Session = Depends(get_db)):
    return list_all_permisos_by_user(db, user_id)

@router.post("/role/{role_id}", response_model=list[PermisoRoleResponse])
def assing_permiso_to_role_endpoint(Permiso_role: PermisoRoleAssing, db: Session = Depends(get_db)):
    return assing_permiso_to_role(db, Permiso_role.role_id, Permiso_role.permiso_id)

@router.get("/role/list/{role_id}", response_model=list[PermisoRoleResponse])
def list_permisos_by_role_get_endpoint(role_id: int, db: Session = Depends(get_db)):
    return list_permisos_by_role(db, role_id)

    