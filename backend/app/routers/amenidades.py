from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.amenidad import AmenidadCreate, AmenidadResponse
from app.services.amenidades import create_amenidad as create_amenidad_service, update_amenidad as update_amenidad_service, delete_amenidad as delete_amenidad_service, show_amenidad as show_amenidad_service, list_all_amenidades
from app.routers.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/amenidades", tags=["Amenidades"])

@router.post("/", response_model=AmenidadResponse)
def create_amenidad(amenidad: AmenidadCreate, db: Session = Depends(get_db)):
    return create_amenidad_service(db, amenidad)

@router.get("/list/", response_model=list[AmenidadResponse])
def list_amenidades(db: Session = Depends(get_db)):
    return list_all_amenidades(db)

@router.put("/{amenidad_id}", response_model=AmenidadResponse)
def update_amenidad(amenidad_id: int, amenidad: AmenidadCreate, db: Session = Depends(get_db)):
    return update_amenidad_service(db, amenidad_id, amenidad)

@router.get("/{amenidad_id}", response_model=AmenidadResponse)
def show_amenidad(amenidad_id: int, db: Session = Depends(get_db)):
    return show_amenidad_service(db, amenidad_id)

@router.delete("/{amenidad_id}")
def delete_amenidad(amenidad_id: int, db: Session = Depends(get_db)):
    return delete_amenidad_service(db, amenidad_id)
