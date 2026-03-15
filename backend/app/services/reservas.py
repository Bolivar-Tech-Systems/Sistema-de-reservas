from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from passlib.context import CryptContext
from app.models.reservas import Reserva, Disponibilidad, ReservaUsuario
from app.schemas.reservas import ReservaCreate, DisponibilidadCreate, ReservaUsuarioCreate, ReservaResponse, DisponibilidadResponse, ReservaUsuarioResponse

def create_reserva(db: Session, reserva: ReservaCreate, owner_id: int):
    new_reserva = db.query(Reserva).filter(Reserva.name == reserva.name).first()
    if new_reserva:
        raise HTTPException(status_code=400, detail="Reserva already exists")
    else:
        try:
            new_reserva = Reserva(name=reserva.name, description=reserva.description, owner_id=owner_id)
            db.add(new_reserva)
            db.commit()
            db.refresh(new_reserva)
            return new_reserva
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def update_reserva(db: Session, reserva_id: int, reserva: ReservaCreate, owner_id: int):
    db_reserva = db.query(Reserva).filter(Reserva.id == reserva_id, Reserva.owner_id == owner_id).first()
    if not db_reserva:
        raise HTTPException(status_code=404, detail="Reserva not found")
    else:
        try:
            db_reserva.name = reserva.name
            db_reserva.description = reserva.description
            db.commit()
            db.refresh(db_reserva)
            return db_reserva
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_reserva(db: Session, reserva_id: int, owner_id: int):
    db_reserva = db.query(Reserva).filter(Reserva.id == reserva_id, Reserva.owner_id == owner_id).first()
    if not db_reserva:
        raise HTTPException(status_code=404, detail="Reserva not found")
    else:
        try:
            db.delete(db_reserva)
            db.commit()
            return {"detail": "Reserva deleted"}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def show_reserva(db: Session, reserva_id: int, owner_id: int):
    db_reserva = db.query(Reserva).filter(Reserva.id == reserva_id, Reserva.owner_id == owner_id).first()
    if not db_reserva:
        raise HTTPException(status_code=404, detail="Reserva not found")
    else:
        return db_reserva
    
        
def create_disponibilidad(db: Session, disponibilidad: DisponibilidadCreate):
    new_disponibilidad = db.query(Disponibilidad).filter(Disponibilidad.date == disponibilidad.date, Disponibilidad.time == disponibilidad.time, Disponibilidad.reserva_id == disponibilidad.reserva_id).first()
    if new_disponibilidad:
        raise HTTPException(status_code=400, detail="Disponibilidad already exists")
    else:
        try:
            new_disponibilidad = Disponibilidad(date=disponibilidad.date, time=disponibilidad.time, reserva_id=disponibilidad.reserva_id)
            db.add(new_disponibilidad)
            db.commit()
            db.refresh(new_disponibilidad)
            return new_disponibilidad
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))

def update_disponibilidad(db: Session, disponibilidad_id: int, disponibilidad: DisponibilidadCreate):
    db_disponibilidad = db.query(Disponibilidad).filter(Disponibilidad.id == disponibilidad_id).first()
    if not db_disponibilidad:
        raise HTTPException(status_code=404, detail="Disponibilidad not found")
    else:
        try:
            db_disponibilidad.date = disponibilidad.date
            db_disponibilidad.time = disponibilidad.time
            db_disponibilidad.reserva_id = disponibilidad.reserva_id
            db.commit()
            db.refresh(db_disponibilidad)
            return db_disponibilidad
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_disponibilidad(db: Session, disponibilidad_id: int):
    db_disponibilidad = db.query(Disponibilidad).filter(Disponibilidad.id == disponibilidad_id).first()
    if not db_disponibilidad:
        raise HTTPException(status_code=404, detail="Disponibilidad not found")
    else:
        try:
            db.delete(db_disponibilidad)
            db.commit()
            return {"detail": "Disponibilidad deleted"}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def show_disponibilidad(db: Session, disponibilidad_id: int):
    db_disponibilidad = db.query(Disponibilidad).filter(Disponibilidad.id == disponibilidad_id).first()
    if not db_disponibilidad:
        raise HTTPException(status_code=404, detail="Disponibilidad not found")
    else:
        return db_disponibilidad
        
def create_reserva_usuario(db: Session, reserva_usuario: ReservaUsuarioCreate, user_id: int):
    new_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.reserva_id == reserva_usuario.reserva_id, ReservaUsuario.user_id == user_id).first()
    if new_reserva_usuario:
        raise HTTPException(status_code=400, detail="ReservaUsuario already exists")
    else:
        try:
            new_reserva_usuario = ReservaUsuario(reserva_id=reserva_usuario.reserva_id, user_id=user_id, fecha_inicio=reserva_usuario.fecha_inicio, fecha_fin=reserva_usuario.fecha_fin, hora_inicio=reserva_usuario.hora_inicio, hora_fin=reserva_usuario.hora_fin, estado= reserva_usuario.estado)
            disponible = db.query(Disponibilidad).filter(
                Disponibilidad.reserva_id == reserva_usuario.reserva_id, 
                Disponibilidad.fecha_inicio <= new_reserva_usuario.fecha_inicio,
                Disponibilidad.fecha_fin >= new_reserva_usuario.fecha_fin,
                Disponibilidad.hora_inicio <= new_reserva_usuario.hora_inicio,
                Disponibilidad.hora_fin >= new_reserva_usuario.hora_fin
            ).first()
            if not disponible:
                raise HTTPException(status_code=400, detail="No disponible")
            db.add(new_reserva_usuario)
            db.commit()
            db.refresh(new_reserva_usuario)
            return new_reserva_usuario
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def update_reserva_usuario(db: Session, reserva_usuario_id: int, reserva_usuario: ReservaUsuarioCreate,user_id: int):
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.user_id == user_id).first()
    if not db_reserva_usuario:
        raise HTTPException(status_code=404, detail="ReservaUsuario not found")
    else:
        try:
            db_reserva_usuario.reserva_id = reserva_usuario.reserva_id
            db_reserva_usuario.fecha_inicio = reserva_usuario.fecha_inicio
            db_reserva_usuario.fecha_fin = reserva_usuario.fecha_fin
            db_reserva_usuario.hora_inicio = reserva_usuario.hora_inicio
            db_reserva_usuario.hora_fin = reserva_usuario.hora_fin
            db_reserva_usuario.estado = reserva_usuario.estado
            db.commit()
            db.refresh(db_reserva_usuario)
            return db_reserva_usuario
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_reserva_usuario(db: Session, reserva_usuario_id: int, user_id: int):
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.user_id == user_id).first()
    if not db_reserva_usuario:
        raise HTTPException(status_code=404, detail="ReservaUsuario not found")
    else:
        try:
            db.delete(db_reserva_usuario)
            db.commit()
            return {"detail": "ReservaUsuario deleted"}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))

def show_reserva_usuario(db: Session, reserva_usuario_id: int, user_id: int):
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.user_id == user_id).first()
    if not db_reserva_usuario:
        raise HTTPException(status_code=404, detail="ReservaUsuario not found")
    else:
        return db_reserva_usuario

