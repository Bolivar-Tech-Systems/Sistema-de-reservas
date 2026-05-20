import traceback
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.reservas import Recurso
from app.models.user import User


def _exists_favorito(db: Session, user_id: int, recurso_id: int) -> bool:
    """Verifica de forma eficiente si un recurso es favorito del usuario usando el ORM."""
    return db.query(User).filter(
        User.id == user_id,
        User.favoritos.any(Recurso.id == recurso_id)
    ).first() is not None


def toggle_favorito(db: Session, user_id: int, recurso_id: int):
    """Agrega o quita un recurso de favoritos usando relaciones ORM."""
    recurso = db.query(Recurso).filter(Recurso.id == recurso_id).first()
    if not recurso:
        raise HTTPException(status_code=404, detail="Recurso no encontrado")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    try:
        # Usar la relación de SQLAlchemy (muchos a muchos) para evitar usar db.execute()
        # que entra en conflicto con el plugin de auditoría de sqlalchemy-continuum
        if recurso in user.favoritos:
            user.favoritos.remove(recurso)
            db.commit()
            return {"favorito": False, "detail": "Eliminado de favoritos"}
        else:
            user.favoritos.append(recurso)
            db.commit()
            return {"favorito": True, "detail": "Agregado a favoritos"}
    except Exception as e:
        db.rollback()
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Error al actualizar favoritos: {repr(e)}"
        )


def list_favoritos(db: Session, user_id: int):
    """Lista todos los recursos favoritos de un usuario."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user.favoritos


def is_favorito(db: Session, user_id: int, recurso_id: int):
    """Verifica si un recurso es favorito del usuario."""
    return {"favorito": _exists_favorito(db, user_id, recurso_id)}
