from sqlalchemy import Column, Integer, String, Float, Text, Boolean, DateTime, ForeignKey, Table, Enum
from sqlalchemy.orm import relationship
from app.core.database import Base

class Categoria(Base):
    __tablename__ = "categoria"
    __versioned__ = {}
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), unique=True, index=True)
    descripcion = Column(String)
    icono = Column(String) 
    
    recursos = relationship("Recurso", back_populates="categoria")