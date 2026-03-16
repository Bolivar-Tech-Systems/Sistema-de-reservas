from fastapi import APIRouter, Depends
from langcodes import get
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.reservas import ReservaCreate, DisponibilidadCreate, ReservaUsuarioCreate, ReservaResponse, DisponibilidadResponse, ReservaUsuarioResponse
from app.services.reservas import create_reserva, list_all_reservas, list_all_reservas_usuario, list_disponibilidades_by_reserva, update_reserva, delete_reserva, show_reserva, create_disponibilidad, update_disponibilidad, delete_disponibilidad, show_disponibilidad, create_reserva_usuario, update_reserva_usuario, delete_reserva_usuario, show_reserva_usuario
from app.routers.auth import get_current_user

router = APIRouter(prefix="/reservas", tags=["reservas"])

@router.post("/", response_model=ReservaResponse)
def create_reserva_endpoint(reserva: ReservaCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return create_reserva(db, reserva, current_user.id)

@router.put("/{reserva_id}", response_model=ReservaResponse)
def update_reserva_endpoint(reserva_id: int, reserva: ReservaCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return update_reserva(db, reserva_id, reserva, current_user)

@router.get("/{reserva_id}", response_model=ReservaResponse)
def show_reserva_endpoint(reserva_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return show_reserva(db, reserva_id, current_user)

@router.delete("/{reserva_id}")
def delete_reserva_endpoint(reserva_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    return delete_reserva(db, reserva_id, current_user)

@router.post("/disponibilidad/", response_model=DisponibilidadResponse)
def create_disponibilidad_endpoint(disponibilidad: DisponibilidadCreate, db: Session = Depends(get_db)):
    return create_disponibilidad(db, disponibilidad)

@router.put("/disponibilidad/{disponibilidad_id}", response_model=DisponibilidadResponse)
def update_disponibilidad_endpoint(disponibilidad_id: int, disponibilidad: DisponibilidadCreate, db: Session = Depends(get_db)):
    return update_disponibilidad(db, disponibilidad_id, disponibilidad)

@router.get("/disponibilidad/{disponibilidad_id}", response_model=DisponibilidadResponse)
def show_disponibilidad_endpoint(disponibilidad_id: int, db: Session = Depends(get_db)):
    return show_disponibilidad(db, disponibilidad_id)

@router.get("/disponibilidad/{reserva_id}", response_model=list[DisponibilidadResponse])
def list_disponibilidades_by_reserva_endpoint(reserva_id: int, db: Session = Depends(get_db)):
    return list_disponibilidades_by_reserva(db, reserva_id)

@router.delete("/disponibilidad/{disponibilidad_id}")
def delete_disponibilidad_endpoint(disponibilidad_id: int, db: Session = Depends(get_db)):
    return delete_disponibilidad(db, disponibilidad_id)

@router.post("/reserva_usuario/", response_model=ReservaUsuarioResponse)
def create_reserva_usuario_endpoint(reserva_usuario: ReservaUsuarioCreate, db: Session = Depends(get_db)):
    return create_reserva_usuario(db, reserva_usuario)

@router.put("/reserva_usuario/{reserva_usuario_id}", response_model=ReservaUsuarioResponse)
def update_reserva_usuario_endpoint(reserva_usuario_id: int, reserva_usuario: ReservaUsuarioCreate, db: Session = Depends(get_db)):
    return update_reserva_usuario(db, reserva_usuario_id, reserva_usuario)  

@router.get("/reserva_usuario/{reserva_usuario_id}", response_model=ReservaUsuarioResponse)
def show_reserva_usuario_endpoint(reserva_usuario_id: int, db: Session = Depends(get_db)):
    return show_reserva_usuario(db, reserva_usuario_id)

@router.delete("/reserva_usuario/{reserva_usuario_id}")
def delete_reserva_usuario_endpoint(reserva_usuario_id: int, db: Session = Depends(get_db)):
    return delete_reserva_usuario(db, reserva_usuario_id)

@router.get("/reservas_usuario/", response_model=list[ReservaUsuarioResponse])
def list_reservas_usuario_endpoint(user_id: int, db: Session = Depends(get_db)):
    return list_all_reservas_usuario(db, user_id)

@router.get("/list/", response_model=list[ReservaResponse])
def list_reservas_endpoint(db: Session = Depends(get_db)):
    return list_all_reservas(db)
