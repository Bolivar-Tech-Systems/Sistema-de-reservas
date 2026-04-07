from supabase import create_client, Client
from app.core.config import SUPABASE_URL, SUPABASE_KEY, SUPABASE_BUCKET_NAME
from fastapi import HTTPException, status, UploadFile
from app.models.images import ImageReserva
from app.models.reservas import Reserva
from app.schemas.images import ImageCreate
from sqlalchemy.orm import Session

def get_supabase_client() -> Client:
    return create_client(SUPABASE_URL, SUPABASE_KEY)

async def upload_image(db: Session, image: ImageCreate, user_id: int, file: UploadFile, reserva_id: int):
    try:
        image_read = await file.read()
        response = get_supabase_client().storage.from_(SUPABASE_BUCKET_NAME).upload(f"{user_id}/{image.file_name}", image_read, file_options={"content-type": file.content_type})
        image_url = f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET_NAME}/{user_id}/{image.file_name}"
        new_image = ImageReserva(url_image_reserva=image_url, reserva_id=reserva_id)
        db.add(new_image)
        db.commit()
        db.refresh(new_image)  
        return image_url
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
    
def list_images_by_reserva(db: Session, reserva_id: int):
    images = db.query(ImageReserva).filter(ImageReserva.reserva_id == reserva_id).all()
    if not images:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron imágenes para esta reserva")
    return images

def list_images_by_user(db: Session, user_id: int):
    images = db.query(ImageReserva).join(Reserva).filter(Reserva.owner_id == user_id).all()
    if not images:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron imágenes para este usuario")
    return images

def list_all_images(db: Session):
    images = db.query(ImageReserva).all()
    if not images:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron imágenes")
    return images
