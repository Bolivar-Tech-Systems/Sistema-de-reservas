from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.audit import AuditLogResponse, HistoryVersionResponse
from app.services.audit import get_http_logs, get_model_history
from app.routers.auth import get_current_user
from app.models.user import User
from app.models.reservas import Recurso, ReservaUsuario

router = APIRouter(prefix="/auditoria", tags=["Auditoria"])

@router.get("/http-logs", response_model=list[AuditLogResponse])
def read_http_logs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Solo admin debería ver esto en un caso real, pero por ahora permitimos a current_user
    return get_http_logs(db, skip=skip, limit=limit)

@router.get("/historial/recurso/{recurso_id}", response_model=list[HistoryVersionResponse])
def read_recurso_history(recurso_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return get_model_history(db, Recurso, recurso_id)

@router.get("/historial/reserva/{reserva_id}", response_model=list[HistoryVersionResponse])
def read_reserva_history(reserva_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return get_model_history(db, ReservaUsuario, reserva_id)
