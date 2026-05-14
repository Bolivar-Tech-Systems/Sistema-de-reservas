from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.categoria import CategoriaCreate, CategoriaResponse
from app.services.categorias import (create_categoria as create_categoria_service, update_categoria as update_categoria_service, delete_categoria as delete_categoria_service, show_categoria as show_categoria_service, list_all_categorias, )
from app.routers.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/categorias", tags=["Categorias"])

@router.post("/", response_model=CategoriaResponse)
def create_categoria(categoria: CategoriaCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return create_categoria_service(db, categoria, current_user.id)

@router.get("/list/", response_model=list[CategoriaResponse])
def list_categorias(db: Session = Depends(get_db)):
    return list_all_categorias(db)

@router.put("/{categoria_id}", response_model=CategoriaResponse)
def update_categoria(categoria_id: int, categoria: CategoriaCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return update_categoria_service(db, categoria_id, categoria, current_user.id)

@router.get("/{categoria_id}", response_model=CategoriaResponse)
def show_categoria(categoria_id: int, db: Session = Depends(get_db), ):
    return show_categoria_service(db, categoria_id)

@router.delete("/{categoria_id}")
def delete_categoria(categoria_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return delete_categoria_service(db, categoria_id, current_user.id)
