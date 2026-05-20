from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.reservas import Recurso
from app.models.user import User
from app.models.asociaciones import user_favorites
from sqlalchemy import and_


def toggle_favorito(db: Session, user_id: int, recurso_id: int):
    """Agrega o quita un recurso de favoritos (toggle)."""
    recurso = db.query(Recurso).filter(Recurso.id == recurso_id).first()
    if not recurso:
        raise HTTPException(status_code=404, detail="Recurso no encontrado")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    # Verificar si ya es favorito
    exists = db.execute(
        user_favorites.select().where(and_(
            user_favorites.c.user_id == user_id,
            user_favorites.c.recurso_id == recurso_id,
        ))
    ).first()

    try:
        if exists:
            db.execute(
                user_favorites.delete().where(and_(
                    user_favorites.c.user_id == user_id,
                    user_favorites.c.recurso_id == recurso_id,
                ))
            )
            db.commit()
            return {"favorito": False, "detail": "Eliminado de favoritos"}
        else:
            db.execute(
                user_favorites.insert().values(user_id=user_id, recurso_id=recurso_id)
            )
            db.commit()
            return {"favorito": True, "detail": "Agregado a favoritos"}
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


def list_favoritos(db: Session, user_id: int):
    """Lista todos los recursos favoritos de un usuario."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user.favoritos


def is_favorito(db: Session, user_id: int, recurso_id: int):
    """Verifica si un recurso es favorito del usuario."""
    exists = db.execute(
        user_favorites.select().where(and_(
            user_favorites.c.user_id == user_id,
            user_favorites.c.recurso_id == recurso_id,
        ))
    ).first()
    return {"favorito": exists is not None}
