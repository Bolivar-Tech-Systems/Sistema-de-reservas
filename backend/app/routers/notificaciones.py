from fastapi import APIRouter, Depends
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.notificaciones import NotificacionCreate, NotificacionMasiva
from app.services.notificaciones_services import (crear_notificacion,enviar_a_todos,listar_todas,listar_por_usuario,marcar_leida,marcar_todas_leidas,eliminar_notificacion, )
from sqlalchemy.orm import Session
from app.core.database import get_db

router = APIRouter(prefix="/notificaciones", tags=["Notificaciones"])


@router.post("/enviar")
def enviar_notificacion(data: NotificacionCreate,current_user: User = Depends(get_current_user),):
    """Envía una notificación a un usuario específico."""
    crear_notificacion(
        id_usuario=str(data.id_usuario),
        titulo=data.titulo,
        mensaje=data.mensaje,
        tipo=data.tipo,
    )
    return {"detail": "Notificación enviada"}


@router.post("/enviar-todos")
def enviar_a_todos_endpoint(
    data: NotificacionMasiva,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Envía una notificación a todos los usuarios registrados."""
    usuarios = db.query(User.id).all()
    ids = [str(u.id) for u in usuarios]
    enviar_a_todos(
        usuarios=ids,
        titulo=data.titulo,
        mensaje=data.mensaje,
        tipo=data.tipo,
    )
    return {"detail": f"Notificación enviada a {len(ids)} usuarios"}


@router.get("/")
def listar(current_user: User = Depends(get_current_user)):
    """Lista todas las notificaciones."""
    return listar_todas()


@router.get("/usuario/{id_usuario}")
def listar_usuario(
    id_usuario: str,
    current_user: User = Depends(get_current_user),
):
    """Lista las notificaciones de un usuario específico."""
    return listar_por_usuario(id_usuario)


@router.put("/{doc_id}/leida")
def marcar_como_leida(
    doc_id: str,
    current_user: User = Depends(get_current_user),
):
    """Marca una notificación como leída."""
    marcar_leida(doc_id)
    return {"detail": "Notificación marcada como leída"}


@router.put("/leidas/{id_usuario}")
def marcar_todas_como_leidas(
    id_usuario: str,
    current_user: User = Depends(get_current_user),
):
    """Marca todas las notificaciones de un usuario como leídas."""
    marcar_todas_leidas(id_usuario)
    return {"detail": "Todas las notificaciones marcadas como leídas"}


@router.delete("/{doc_id}")
def eliminar(
    doc_id: str,
    current_user: User = Depends(get_current_user),
):
    """Elimina una notificación."""
    eliminar_notificacion(doc_id)
    return {"detail": "Notificación eliminada"}
