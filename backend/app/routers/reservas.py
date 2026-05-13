from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.reservas import RecursoCreate, DisponibilidadCreate, ReservaUsuarioCreate, RecursoResponse, DisponibilidadResponse, ReservaUsuarioResponse
from app.services.reservas import create_recurso, list_all_recursos, list_all_reservas_usuario, list_disponibilidades_by_recurso, create_disponibilidad, update_disponibilidad, delete_disponibilidad, show_disponibilidad, create_reserva_usuario, update_reserva_usuario, delete_reserva_usuario, show_reserva_usuario
from app.routers.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/reservas", tags=["reservas"])

@router.post("/", response_model=RecursoResponse)
def create_recurso(recurso: RecursoCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return create_recurso(db, recurso, current_user.id)

@router.put("/{recurso_id}", response_model=RecursoResponse)
def update_recurso(recurso_id: int, recurso: RecursoCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return update_recurso(db, recurso_id, recurso, current_user.id)

@router.get("/{recurso_id}", response_model=RecursoResponse)
def show_recurso(recurso_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return show_recurso(db, recurso_id)

@router.delete("/{recurso_id}")
def delete_recurso(recurso_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return delete_recurso(db, recurso_id, current_user.id)

@router.post("/disponibilidad/", response_model=DisponibilidadResponse)
def create_disponibilidad_endpoint(disponibilidad: DisponibilidadCreate, db: Session = Depends(get_db)):
    return create_disponibilidad(db, disponibilidad)

@router.put("/disponibilidad/{disponibilidad_id}", response_model=DisponibilidadResponse)
def update_disponibilidad_endpoint(disponibilidad_id: int, disponibilidad: DisponibilidadCreate, db: Session = Depends(get_db)):
    return update_disponibilidad(db, disponibilidad_id, disponibilidad)

@router.get("/disponibilidad/{disponibilidad_id}", response_model=DisponibilidadResponse)
def show_disponibilidad_endpoint(disponibilidad_id: int, db: Session = Depends(get_db)):
    return show_disponibilidad(db, disponibilidad_id)

@router.get("/disponibilidad/recurso/{recurso_id}", response_model=list[DisponibilidadResponse])
def list_disponibilidades_by_recurso(recurso_id: int, db: Session = Depends(get_db)):
    return list_disponibilidades_by_recurso(db, recurso_id)

@router.delete("/disponibilidad/{disponibilidad_id}")
def delete_disponibilidad_endpoint(disponibilidad_id: int, db: Session = Depends(get_db)):
    return delete_disponibilidad(db, disponibilidad_id)

@router.post("/reserva_usuario/", response_model=ReservaUsuarioResponse)
def create_reserva_usuario_endpoint(reserva_usuario: ReservaUsuarioCreate, db: Session = Depends(get_db), user_id: User = Depends(get_current_user)):
    return create_reserva_usuario(db, reserva_usuario, user_id.id)

@router.put("/reserva_usuario/{reserva_usuario_id}", response_model=ReservaUsuarioResponse)
def update_reserva_usuario_endpoint(reserva_usuario_id: int, reserva_usuario: ReservaUsuarioCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return update_reserva_usuario(db, reserva_usuario_id, reserva_usuario, user.id)  

@router.get("/reserva_usuario/{reserva_usuario_id}", response_model=ReservaUsuarioResponse)
def show_reserva_usuario_endpoint(reserva_usuario_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return show_reserva_usuario(db, reserva_usuario_id, user.id)

@router.delete("/reserva_usuario/{reserva_usuario_id}")
def delete_reserva_usuario_endpoint(reserva_usuario_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return delete_reserva_usuario(db, reserva_usuario_id, user.id)

@router.get("/reservas_usuario/", response_model=list[ReservaUsuarioResponse])
def list_reservas_usuario_endpoint(user_id: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return list_all_reservas_usuario(db, user_id.id)

@router.get("/list/", response_model=list[RecursoResponse])
def list_recursos(db: Session = Depends(get_db)):
    return list_all_recursos(db)
