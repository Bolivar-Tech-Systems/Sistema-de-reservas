from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.amenidad import Amenidad
from app.schemas.amenidad import AmenidadCreate

def create_amenidad(db: Session, amenidad: AmenidadCreate):
    new_amenidad = db.query(Amenidad).filter(Amenidad.nombre == amenidad.nombre).first()
    if new_amenidad:
        raise HTTPException(status_code=400, detail="Amenidad already exists")
    else:
        try:
            new_amenidad = Amenidad(
                nombre=amenidad.nombre,
                icono=amenidad.icono,
            )
            db.add(new_amenidad)
            db.commit()
            db.refresh(new_amenidad)
            return new_amenidad
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def update_amenidad(db: Session, amenidad_id: int, amenidad: AmenidadCreate):
    db_amenidad = db.query(Amenidad).filter(Amenidad.id == amenidad_id).first()
    if not db_amenidad:
        raise HTTPException(status_code=404, detail="Amenidad not found")
    else:
        try:
            db_amenidad.nombre = amenidad.nombre
            db_amenidad.icono = amenidad.icono
            db.commit()
            db.refresh(db_amenidad)
            return db_amenidad
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def delete_amenidad(db: Session, amenidad_id: int):
    db_amenidad = db.query(Amenidad).filter(Amenidad.id == amenidad_id).first()
    if not db_amenidad:
        raise HTTPException(status_code=404, detail="Amenidad not found")
    else:
        try:
            db.delete(db_amenidad)
            db.commit()
            return {"detail": "Amenidad deleted"}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))
        
def show_amenidad(db: Session, amenidad_id: int):
    db_amenidad = db.query(Amenidad).filter(Amenidad.id == amenidad_id).first()
    if not db_amenidad:
        raise HTTPException(status_code=404, detail="Categoria not found")
    else:
        return db_amenidad

def list_amenidad(db: Session, owner_id: int):
    db_list_amenidad = db.query(Amenidad).all()
    if not db_list_amenidad:
        raise HTTPException(status_code=404, detail="No amenidades found")
    return db_list_amenidad

def list_all_amenidades(db: Session):
    db_categorias = db.query(Amenidad).all()
    return db_categorias
