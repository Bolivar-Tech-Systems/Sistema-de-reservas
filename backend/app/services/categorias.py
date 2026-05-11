from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.categoria import Categoria
from app.schemas.categoria import CategoriaCreate

def create_categoria(db: Session, categoria: CategoriaCreate, owner_id: int):
    new_categoria = db.query(Categoria).filter(Categoria.nombre == categoria.nombre).first()
    if new_categoria:
        raise HTTPException(status_code=400, detail="Categoria already exists")
    else:
        try:
            new_categoria = Categoria(
                nombre=categoria.nombre,
                descripcion=categoria.descripcion,
                icono=categoria.icono,
            )
            db.add(new_categoria)
            db.commit()
            db.refresh(new_categoria)
            return new_categoria
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def update_categoria(db: Session, categoria_id: int, categoria: CategoriaCreate, owner_id: int):
    db_categoria = db.query(Categoria).filter(Categoria.id == categoria_id).first()
    if not db_categoria:
        raise HTTPException(status_code=404, detail="Categoria not found")
    else:
        try:
            db_categoria.nombre = categoria.nombre
            db_categoria.descripcion = categoria.descripcion
            db_categoria.icono = categoria.icono
            db.commit()
            db.refresh(db_categoria)
            return db_categoria
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_categoria(db: Session, categoria_id: int, owner_id: int):
    db_categoria = db.query(Categoria).filter(Categoria.id == categoria_id).first()
    if not db_categoria:
        raise HTTPException(status_code=404, detail="Categoria not found")
    else:
        try:
            db.delete(db_categoria)
            db.commit()
            return {"detail": "Categoria deleted"}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def show_categoria(db: Session, categoria_id: int):
    db_categoria = db.query(Categoria).filter(Categoria.id == categoria_id).first()
    if not db_categoria:
        raise HTTPException(status_code=404, detail="Categoria not found")
    else:
        return db_categoria

def list_categoria(db: Session, owner_id: int):
    db_list_categoria = db.query(Categoria).all()
    if not db_list_categoria:
        raise HTTPException(status_code=404, detail="No categorias found")
    return db_list_categoria

def list_all_categorias(db: Session):
    db_categorias = db.query(Categoria).all()
    return db_categorias
