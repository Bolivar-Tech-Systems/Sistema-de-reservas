from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Form 
from httpx import post
from sqlalchemy.orm import Session
from app.services.images import list_all_images, list_images_by_reserva, list_images_by_user, upload_image
from app.core.database import get_db
from app.core.database import get_db
from app.schemas.images import ImageCreate, ImageResponse
from app.routers.auth import get_current_user

router = APIRouter(prefix="/images", tags=["images"])

@router.post("/upload")
async def upload_image_endpoint(db: Session = Depends(get_db), current_user: int = Depends(get_current_user), file: UploadFile = File(...), file_name: str = Form(...), reserva_id: int = Form(...)):
    image = ImageCreate(file_name=file_name)
    return await upload_image(db, image, current_user.id, file, reserva_id)

@router.get("/reserva/{reserva_id}", response_model=list[ImageResponse])
def list_images_by_reserva_endpoint(reserva_id: int, db: Session = Depends(get_db)):
    return list_images_by_reserva(db, reserva_id)

@router.get("/user/{user_id}", response_model=list[ImageResponse])
def list_images_by_user_endpoint(user_id: int, db: Session = Depends(get_db)):
    return list_images_by_user(db, user_id)

@router.get("/all", response_model=list[ImageResponse])
def list_all_images_endpoint(db: Session = Depends(get_db)):
    return list_all_images(db)