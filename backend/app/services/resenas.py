from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException
from app.models.reservas import Resena, Recurso
from app.schemas.reservas import ResenaCreate


def create_resena(db: Session, resena: ResenaCreate, user_id: int):
    # Verificar que el recurso existe
    recurso = db.query(Recurso).filter(Recurso.id == resena.recurso_id).first()
    if not recurso:
        raise HTTPException(status_code=404, detail="Recurso no encontrado")

    # Verificar que el usuario no haya dejado ya una reseña para este recurso
    existing = db.query(Resena).filter(
        Resena.recurso_id == resena.recurso_id,
        Resena.usuario_id == user_id,
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Ya dejaste una reseña para este recurso")

    # Validar calificación 1-5
    if resena.calificacion < 1 or resena.calificacion > 5:
        raise HTTPException(status_code=400, detail="La calificación debe ser entre 1 y 5")

    try:
        new_resena = Resena(
            recurso_id=resena.recurso_id,
            usuario_id=user_id,
            calificacion=resena.calificacion,
            comentario=resena.comentario,
        )
        db.add(new_resena)
        db.commit()
        db.refresh(new_resena)

        # Recalcular calificación promedio del recurso
        _recalcular_promedio(db, resena.recurso_id)

        return new_resena
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


def list_resenas_by_recurso(db: Session, recurso_id: int):
    return db.query(Resena).filter(Resena.recurso_id == recurso_id).order_by(Resena.created_at.desc()).all()


def delete_resena(db: Session, resena_id: int, user_id: int, is_admin: bool = False):
    if is_admin:
        resena = db.query(Resena).filter(Resena.id == resena_id).first()
    else:
        resena = db.query(Resena).filter(Resena.id == resena_id, Resena.usuario_id == user_id).first()

    if not resena:
        raise HTTPException(status_code=404, detail="Reseña no encontrada")

    recurso_id = resena.recurso_id
    try:
        db.delete(resena)
        db.commit()
        _recalcular_promedio(db, recurso_id)
        return {"detail": "Reseña eliminada"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


def _recalcular_promedio(db: Session, recurso_id: int):
    avg = db.query(func.avg(Resena.calificacion)).filter(Resena.recurso_id == recurso_id).scalar()
    recurso = db.query(Recurso).filter(Recurso.id == recurso_id).first()
    if recurso:
        recurso.calificacion_promedio = round(float(avg), 2) if avg else 0
        db.commit()
