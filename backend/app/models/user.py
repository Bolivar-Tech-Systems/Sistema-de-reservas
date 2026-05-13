from datetime import datetime
from sqlalchemy import Column, ForeignKey, Integer, String, DateTime
from sqlalchemy.orm import relationship
from app.models.asociaciones import user_favorites
from app.core.database import Base

class User(Base):
    __tablename__ = "users"
    __versioned__ = {}
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column("name", String, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    telefono = Column(String, nullable=True)
    foto_perfil = Column(String, nullable=True)
    role_id = Column(Integer, ForeignKey("roles.id"))
    reset_code = Column(String(10), nullable=True)
    reset_code_expire = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    role = relationship("Role", back_populates="users")
    recursos_propios = relationship("Recurso", back_populates="owner", foreign_keys="Recurso.owner_id")
    reservas = relationship("ReservaUsuario", back_populates="usuario")
    favoritos = relationship("Recurso", secondary=user_favorites, back_populates="favoritos")

class Role(Base):
    __tablename__ = "roles"
    __versioned__ = {}
    id = Column(Integer, primary_key=True, index=True)
    name_rol = Column(String, unique=True, index=True, default="user")
    description = Column(String)
    
    users = relationship("User", back_populates="role")