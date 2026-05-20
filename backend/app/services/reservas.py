from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.reservas import Recurso, Disponibilidad, ReservaUsuario
from app.schemas.reservas import RecursoCreate, DisponibilidadCreate, ReservaUsuarioCreate
from app.services.notificaciones_services import crear_notificacion

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
        
def delete_recurso_service(db: Session, recurso_id: int, owner_id: int, is_admin: bool = False):
    query = db.query(Recurso).filter(Recurso.id == recurso_id)
    if not is_admin:
        query = query.filter(Recurso.owner_id == owner_id)
    db_recurso = query.first()
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
        
def check_reserva_capacidad(db: Session, recurso_id: int, fecha_inicio, fecha_fin, hora_inicio, hora_fin, cantidad: int, exclude_reserva_id: int = None):
    from datetime import timedelta
    recurso = db.query(Recurso).filter(Recurso.id == recurso_id).first()
    if not recurso:
        raise HTTPException(status_code=404, detail="Recurso no encontrado")
        
    capacidad_maxima = recurso.capacidad
    if capacidad_maxima is None or capacidad_maxima <= 0:
        capacidad_maxima = 1

    # Query all active reservations that overlap in date and time
    query = db.query(ReservaUsuario).filter(
        ReservaUsuario.recurso_id == recurso_id,
        ReservaUsuario.usuario_id == user_id,
        ReservaUsuario.estado.notin_(["Cancelada"]),
        ReservaUsuario.fecha_inicio <= fecha_fin,
        ReservaUsuario.fecha_fin >= fecha_inicio,
        ReservaUsuario.hora_inicio < hora_fin,
        ReservaUsuario.hora_fin > hora_inicio,
    )
    
    if exclude_reserva_id is not None:
        query = query.filter(ReservaUsuario.id != exclude_reserva_id)
        
    overlapping_reservations = query.all()
    
    # Check day by day
    current_date = fecha_inicio
    while current_date <= fecha_fin:
        day_reservations = [
            r for r in overlapping_reservations 
            if r.fecha_inicio <= current_date <= r.fecha_fin
        ]
        
        # Build timeline of events
        events = []
        for r in day_reservations:
            events.append((r.hora_inicio, r.cantidad))
            events.append((r.hora_fin, -r.cantidad))
            
        events.append((hora_inicio, cantidad))
        events.append((hora_fin, -cantidad))
        
        # Sort events: end first at same time
        events.sort(key=lambda x: (x[0], x[1]))
        
        current_occupied = 0
        for time_event, change in events:
            current_occupied += change
            if current_occupied > capacidad_maxima:
                raise HTTPException(
                    status_code=400,
                    detail=f"Capacidad máxima superada. Disponible: {capacidad_maxima - (current_occupied - change)}, Solicitado: {cantidad}"
                )
        current_date += timedelta(days=1)

def create_reserva_usuario(db: Session, reserva_usuario: ReservaUsuarioCreate, user_id: int):
    # ── Verificar solapamiento de reservas y capacidad ──
    check_reserva_capacidad(
        db=db,
        recurso_id=reserva_usuario.recurso_id,
        fecha_inicio=reserva_usuario.fecha_inicio,
        fecha_fin=reserva_usuario.fecha_fin,
        hora_inicio=reserva_usuario.hora_inicio,
        hora_fin=reserva_usuario.hora_fin,
        cantidad=reserva_usuario.cantidad,
    )

    # Validar que el horario solicitado esté dentro de una ventana de disponibilidad
    disponible = db.query(Disponibilidad).filter(
        Disponibilidad.recurso_id == reserva_usuario.recurso_id,
        Disponibilidad.es_disponible == True,
        Disponibilidad.fecha_inicio <= reserva_usuario.fecha_inicio,
        Disponibilidad.fecha_fin >= reserva_usuario.fecha_fin,
        Disponibilidad.hora_inicio <= reserva_usuario.hora_inicio,
        Disponibilidad.hora_fin >= reserva_usuario.hora_fin,
    ).first()
    if not disponible:
        raise HTTPException(status_code=400, detail="El horario seleccionado no está disponible")

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
        db.add(new_reserva_usuario)
        db.commit()
        db.refresh(new_reserva_usuario)

        # Notificar al usuario que su reserva fue creada
        try:
            crear_notificacion(
                id_usuario=str(user_id),
                titulo="Reserva creada",
                mensaje="Tu reserva fue registrada y está pendiente de confirmación. "
        "Recibirás una actualización cuando el administrador apruebe o rechace la solicitud.",
                tipo="confirmada",
            )
        except Exception:
            pass  # Si falla Firestore, no afectar la reserva

        return new_reserva_usuario
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
        
def update_reserva_usuario(db: Session, reserva_usuario_id: int, reserva_usuario: ReservaUsuarioCreate,user_id: int):
    db_reserva_usuario = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_usuario_id, ReservaUsuario.usuario_id == user_id).first()
    if not db_reserva_usuario:
        raise HTTPException(status_code=404, detail="ReservaUsuario not found")
    else:
        if reserva_usuario.estado != "Cancelada":
            check_reserva_capacidad(
                db=db,
                recurso_id=reserva_usuario.recurso_id,
                fecha_inicio=reserva_usuario.fecha_inicio,
                fecha_fin=reserva_usuario.fecha_fin,
                hora_inicio=reserva_usuario.hora_inicio,
                hora_fin=reserva_usuario.hora_fin,
                cantidad=reserva_usuario.cantidad,
                exclude_reserva_id=reserva_usuario_id,
            )
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

            # Notificar al usuario sobre el cambio de estado
            mensajes = {
                "confirmada": "Tu reserva fue confirmada",
                "cancelada": "Tu reserva fue cancelada",
                "pendiente": "Tu reserva está en revisión",
            }
            estado = reserva_usuario.estado
            try:
                crear_notificacion(
                    id_usuario=str(user_id),
                    titulo=f"Reserva {estado}",
                    mensaje=mensajes.get(estado, f"El estado de tu reserva cambió a {estado}"),
                    tipo=estado,
                )
            except Exception:
                pass
            
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

            # Notificar al usuario que su reserva fue eliminada
            try:
                crear_notificacion(
                    id_usuario=str(user_id),
                    titulo="Reserva eliminada",
                    mensaje="Tu reserva fue eliminada",
                    tipo="cancelada",
                )
            except Exception:
                pass
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

def list_reservas_by_recurso(db: Session, recurso_id: int):
    return db.query(ReservaUsuario).filter(ReservaUsuario.recurso_id == recurso_id).all()