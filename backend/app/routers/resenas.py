from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.reservas import ResenaCreate, ResenaResponse
from app.services.resenas import create_resena, list_resenas_by_recurso, delete_resena
from app.routers.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/resenas", tags=["Reseñas"])


@router.post("/", response_model=ResenaResponse)
def create_resena_endpoint(resena: ResenaCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return create_resena(db, resena, current_user.id)


@router.get("/recurso/{recurso_id}", response_model=list[ResenaResponse])
def list_resenas_endpoint(recurso_id: int, db: Session = Depends(get_db)):
    return list_resenas_by_recurso(db, recurso_id)


@router.delete("/{resena_id}")
def delete_resena_endpoint(resena_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    is_admin = (current_user.role_id == 1)
    return delete_resena(db, resena_id, current_user.id, is_admin=is_admin)
