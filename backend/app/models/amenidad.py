from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.models.asociaciones import recurso_amenidades
from app.core.database import Base

class Amenidad(Base):
    __tablename__ = "amenidad"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), unique=True, index=True)  # WiFi, Parking, AC, etc
    icono = Column(String)
    
    recursos = relationship("Recurso", secondary=recurso_amenidades, back_populates="amenidades")

