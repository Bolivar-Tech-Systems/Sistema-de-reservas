from app.core.config import SUPABASE_URL, SUPABASE_KEY, SUPABASE_BUCKET_NAME
from fastapi import HTTPException, status, UploadFile
from app.models.images import ImageRecurso
from app.models.reservas import Recurso
from app.schemas.images import ImageCreate
from sqlalchemy.orm import Session
from typing import Any


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
        get_supabase_client().storage.from_(SUPABASE_BUCKET_NAME).upload(
            f"{user_id}/{image.file_name}",
            image_read,
            file_options={"content-type": file.content_type},
        )
        image_url = f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET_NAME}/{user_id}/{image.file_name}"
        new_image = ImageRecurso(url=image_url, recurso_id=reserva_id)
        db.add(new_image)
        db.commit()
        db.refresh(new_image)
        return image_url
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
