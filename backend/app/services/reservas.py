from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.reservas import Recurso, Disponibilidad, ReservaUsuario
from app.schemas.reservas import RecursoCreate, DisponibilidadCreate, ReservaUsuarioCreate

def create_recurso_service(db: Session, recurso: RecursoCreate, owner_id: int):
    new_recurso = db.query(Recurso).filter(Recurso.nombre == recurso.nombre).first()
    if new_recurso:
        raise HTTPException(status_code=400, detail="Reserva already exists")
    else:
        try:
            new_recurso = Recurso(
                nombre=recurso.nombre,
                descripcion=recurso.descripcion,
                precio_por_hora=recurso.precio_por_hora,
                foto_principal=recurso.foto_principal,
                categoria_id=recurso.categoria_id,
                owner_id=owner_id,
                capacidad=recurso.capacidad,
                es_visible=recurso.es_visible,
            )
            db.add(new_recurso)
            db.commit()
            db.refresh(new_recurso)
            return new_recurso
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def update_recurso_service(db: Session, recurso_id: int, recurso: RecursoCreate, owner_id: int):
    db_recurso = db.query(Recurso).filter(Recurso.id == recurso_id, Recurso.owner_id == owner_id).first()
    if not db_recurso:
        raise HTTPException(status_code=404, detail="Reserva not found")
    else:
        try:
            db_recurso.nombre = recurso.nombre
            db_recurso.descripcion = recurso.descripcion
            db_recurso.precio_por_hora = recurso.precio_por_hora
            db_recurso.foto_principal = recurso.foto_principal
            db_recurso.categoria_id = recurso.categoria_id
            db_recurso.capacidad = recurso.capacidad
            db_recurso.es_visible = recurso.es_visible
            db.commit()
            db.refresh(db_recurso)
            return db_recurso
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_recurso_service(db: Session, recurso_id: int, owner_id: int):
    db_recurso = db.query(Recurso).filter(Recurso.id == recurso_id, Recurso.owner_id == owner_id).first()
    if not db_recurso:
        raise HTTPException(status_code=404, detail="Reserva not found")
    else:
        try:
            db.delete(db_recurso)
            db.commit()
            return {"detail": "Reserva deleted"}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def show_recurso_service(db: Session, recurso_id: int):
    db_recurso = db.query(Recurso).filter(Recurso.id == recurso_id).first()
    if not db_recurso:
        raise HTTPException(status_code=404, detail="Reserva not found")
    else:
        return db_recurso

def list_recurso(db: Session, owner_id: int):
    db_list_recurso = db.query(Recurso).filter(Recurso.owner_id == owner_id).all()
    if not db_list_recurso:
        raise HTTPException(status_code=404, detail="No recursos found")
    return db_list_recurso

def list_all_recursos(db: Session):
    db_recursos = db.query(Recurso).all()
    return db_recursos

def create_disponibilidad(db: Session, disponibilidad: DisponibilidadCreate):
    new_disponibilidad = db.query(Disponibilidad).filter(Disponibilidad.fecha_inicio == disponibilidad.fecha_inicio, Disponibilidad.fecha_fin == disponibilidad.fecha_fin, Disponibilidad.hora_inicio == disponibilidad.hora_inicio, Disponibilidad.hora_fin == disponibilidad.hora_fin, Disponibilidad.recurso_id == disponibilidad.recurso_id).first()
    if new_disponibilidad:
        raise HTTPException(status_code=400, detail="Disponibilidad already exists")
    else:
        try:
            new_disponibilidad = Disponibilidad(
                fecha_inicio=disponibilidad.fecha_inicio,
                fecha_fin=disponibilidad.fecha_fin,
                hora_inicio=disponibilidad.hora_inicio,
                hora_fin=disponibilidad.hora_fin,
                recurso_id=disponibilidad.recurso_id,
                cantidad_disponible=disponibilidad.cantidad_disponible,
                precio_especial=disponibilidad.precio_especial,
                es_disponible=disponibilidad.es_disponible,
            )
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
            db_disponibilidad.fecha_inicio = disponibilidad.fecha_inicio
            db_disponibilidad.fecha_fin = disponibilidad.fecha_fin
            db_disponibilidad.hora_inicio = disponibilidad.hora_inicio
            db_disponibilidad.hora_fin = disponibilidad.hora_fin
            db_disponibilidad.recurso_id = disponibilidad.recurso_id
            db_disponibilidad.cantidad_disponible = disponibilidad.cantidad_disponible
            db_disponibilidad.precio_especial = disponibilidad.precio_especial
            db_disponibilidad.es_disponible = disponibilidad.es_disponible
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
    
def list_disponibilidades_by_recurso_service(db: Session, recurso_id: int):
    return db.query(Disponibilidad).filter(
        Disponibilidad.recurso_id == recurso_id
    ).all()
        
def create_reserva_usuario(db: Session, reserva_usuario: ReservaUsuarioCreate, user_id: int):
    new_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.recurso_id == reserva_usuario.recurso_id, ReservaUsuario.usuario_id == user_id).first()
    if new_reserva_usuario:
        raise HTTPException(status_code=400, detail="ReservaUsuario already exists")
    else:
        try:
            new_reserva_usuario = ReservaUsuario(
                recurso_id=reserva_usuario.recurso_id,
                usuario_id=user_id,
                fecha_inicio=reserva_usuario.fecha_inicio,
                fecha_fin=reserva_usuario.fecha_fin,
                hora_inicio=reserva_usuario.hora_inicio,
                hora_fin=reserva_usuario.hora_fin,
                cantidad=reserva_usuario.cantidad,
                precio_total=reserva_usuario.precio_total,
                estado=reserva_usuario.estado,
                notas=reserva_usuario.notas,
            )
            # disponible = db.query(Disponibilidad).filter(
            #     Disponibilidad.recurso_id == reserva_usuario.recurso_id,

            #     # fechas se cruzan
            #     Disponibilidad.fecha_inicio <= new_reserva_usuario.fecha_fin,
            #     Disponibilidad.fecha_fin >= new_reserva_usuario.fecha_inicio,

            #     # horas se cruzan
            #     Disponibilidad.hora_inicio < new_reserva_usuario.hora_fin,
            #     Disponibilidad.hora_fin > new_reserva_usuario.hora_inicio
            # ).first()
            # if not disponible:
            #     raise HTTPException(status_code=400, detail="No disponible")
            db.add(new_reserva_usuario)
            db.commit()
            db.refresh(new_reserva_usuario)
            return new_reserva_usuario
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def update_reserva_usuario(db: Session, reserva_usuario_id: int, reserva_usuario: ReservaUsuarioCreate,user_id: int):
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.usuario_id == user_id).first()
    if not db_reserva_usuario:
        raise HTTPException(status_code=404, detail="ReservaUsuario not found")
    else:
        try:
            db_reserva_usuario.recurso_id = reserva_usuario.recurso_id
            db_reserva_usuario.fecha_inicio = reserva_usuario.fecha_inicio
            db_reserva_usuario.fecha_fin = reserva_usuario.fecha_fin
            db_reserva_usuario.hora_inicio = reserva_usuario.hora_inicio
            db_reserva_usuario.hora_fin = reserva_usuario.hora_fin
            db_reserva_usuario.cantidad = reserva_usuario.cantidad
            db_reserva_usuario.precio_total = reserva_usuario.precio_total
            db_reserva_usuario.estado = reserva_usuario.estado
            db_reserva_usuario.notas = reserva_usuario.notas
            db.commit()
            db.refresh(db_reserva_usuario)
            return db_reserva_usuario
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_reserva_usuario(db: Session, reserva_usuario_id: int, user_id: int):
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.usuario_id == user_id).first()
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
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.usuario_id == user_id).first()
    if not db_reserva_usuario:
        raise HTTPException(status_code=404, detail="ReservaUsuario not found")
    else:
        return db_reserva_usuario

def list_all_reservas_usuario(db: Session, user_id: int):
    db_reservas_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.usuario_id == user_id).all()
    return db_reservas_usuario
