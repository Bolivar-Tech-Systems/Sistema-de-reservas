from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.reservas import RecursoResponse
from app.services.favoritos import toggle_favorito, list_favoritos, is_favorito
from app.routers.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/favoritos", tags=["Favoritos"])


@router.post("/{recurso_id}")
def toggle_favorito_endpoint(recurso_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return toggle_favorito(db, current_user.id, recurso_id)


@router.get("/", response_model=list[RecursoResponse])
def list_favoritos_endpoint(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return list_favoritos(db, current_user.id)


@router.get("/{recurso_id}/check")
def is_favorito_endpoint(recurso_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return is_favorito(db, current_user.id, recurso_id)
