from app.core.config import SUPABASE_URL, SUPABASE_KEY, SUPABASE_BUCKET_NAME
from fastapi import HTTPException, status, UploadFile
from app.models.images import ImageRecurso
from app.models.reservas import Recurso
from app.models.user import User
from app.schemas.images import ImageCreate
from sqlalchemy.orm import Session
from typing import Any
import uuid
from app.services.notificaciones_services import crear_notificacion
import os
from pathlib import Path


def get_supabase_client() -> Any:
    try:
        from supabase import create_client
    except ImportError as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Dependencia supabase no instalada",
        ) from exc

    return create_client(SUPABASE_URL, SUPABASE_KEY)


async def upload_image(db: Session, image: ImageCreate, user_id: int, file: UploadFile, reserva_id: int):
    try:
        image_read = await file.read()
        ext = file.filename.split(".")[-1] if file.filename else "jpg"
        unique_name = f"{uuid.uuid4()}.{ext}"

        image_url = None

        # Intentar Supabase
        if SUPABASE_URL and SUPABASE_KEY and SUPABASE_BUCKET_NAME:
            try:
                storage_path = f"{user_id}/{unique_name}"
                get_supabase_client().storage.from_(SUPABASE_BUCKET_NAME).upload(
                    storage_path,
                    image_read,
                    file_options={"content-type": file.content_type or "image/jpeg"},
                )
                image_url = f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET_NAME}/{storage_path}"
            except Exception as se:
                print(f"Supabase upload failed: {se}")

        # Fallback local
        if not image_url:
            try:
                static_dir = Path("static/uploads")
                static_dir.mkdir(parents=True, exist_ok=True)
                file_path = static_dir / unique_name
                with open(file_path, "wb") as f:
                    f.write(image_read)

                from app.core.config import APP_HOST
                host = APP_HOST or "https://129-80-171-141.nip.io/api"
                if host.endswith("/"):
                    host = host[:-1]
                image_url = f"{host}/static/uploads/{unique_name}"
            except Exception as le:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Error al subir imagen local: {str(le)}"
                )

        new_image = ImageRecurso(url=image_url, recurso_id=reserva_id)
        db.add(new_image)

        recurso = db.query(Recurso).filter(Recurso.id == reserva_id).first()
        if recurso:
            recurso.foto_principal = image_url

        db.commit()
        db.refresh(new_image)

        return {"url": image_url}

    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


async def upload_profile_image(db: Session, user: User, file: UploadFile) -> str:
    try:
        image_bytes = await file.read()
        ext = file.filename.split('.')[-1].lower() if file.filename else 'jpg'
        unique_name = f"{uuid.uuid4().hex}.{ext}"

        image_url = None

        # Intentar Supabase
        if SUPABASE_URL and SUPABASE_KEY and SUPABASE_BUCKET_NAME:
            try:
                storage_path = f"profiles/{user.id}/{unique_name}"

                # Eliminar anterior
                if user.foto_perfil and f"/storage/v1/object/public/{SUPABASE_BUCKET_NAME}/profiles/" in (user.foto_perfil or ""):
                    old_path = user.foto_perfil.split(f"/storage/v1/object/public/{SUPABASE_BUCKET_NAME}/")[-1]
                    try:
                        get_supabase_client().storage.from_(SUPABASE_BUCKET_NAME).remove([old_path])
                    except Exception:
                        pass

                get_supabase_client().storage.from_(SUPABASE_BUCKET_NAME).upload(
                    storage_path,
                    image_bytes,
                    file_options={"content-type": file.content_type or "image/jpeg"},
                )
                image_url = f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET_NAME}/{storage_path}"
            except Exception as se:
                print(f"Supabase profile upload failed: {se}")

        # Fallback local
        if not image_url:
            try:
                static_dir = Path("static/uploads/profiles")
                static_dir.mkdir(parents=True, exist_ok=True)
                file_path = static_dir / unique_name
                with open(file_path, "wb") as f:
                    f.write(image_bytes)

                from app.core.config import APP_HOST
                host = APP_HOST or "https://129-80-171-141.nip.io/api"
                if host.endswith("/"):
                    host = host[:-1]
                image_url = f"{host}/static/uploads/profiles/{unique_name}"
            except Exception as le:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Error al guardar foto perfil local: {str(le)}"
                )

        user.foto_perfil = image_url
        db.commit()
        db.refresh(user)

        # Notificar
        try:
            crear_notificacion(
                id_usuario=str(user.id),
                titulo="Foto actualizada",
                mensaje="Tu foto de perfil fue actualizada",
                tipo="perfil",
            )
        except Exception:
            pass

        return image_url
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


def list_images_by_reserva(db: Session, reserva_id: int):
    images = db.query(ImageRecurso).filter(ImageRecurso.recurso_id == reserva_id).all()
    if not images:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron imágenes para esta reserva")
    return images


def list_images_by_user(db: Session, user_id: int):
    images = db.query(ImageRecurso).join(Recurso).filter(Recurso.owner_id == user_id).all()
    if not images:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron imágenes para este usuario")
    return images


def list_all_images(db: Session):
    images = db.query(ImageRecurso).all()
    if not images:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron imágenes")
    return images
