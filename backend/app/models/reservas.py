from datetime import datetime
from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey, Text, Float, DateTime, Boolean
from sqlalchemy.orm import relationship
from app.models.asociaciones import recurso_amenidades, user_favorites
from app.core.database import Base

class Recurso(Base):
    __tablename__ = "recurso"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(200), index=True)
    descripcion = Column(Text)
    precio_por_hora = Column(Float)  # o precio_por_dia, depende de tu modelo
    foto_principal = Column(String, nullable=True)
    categoria_id = Column(Integer, ForeignKey("categoria.id"))
    owner_id = Column(Integer, ForeignKey("users.id"))
    capacidad = Column(Integer, nullable=True)  # personas o unidades
    calificacion_promedio = Column(Float, default=0)
    es_visible = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    categoria = relationship("Categoria", back_populates="recursos")
    owner = relationship("User", back_populates="recursos_propios", foreign_keys=[owner_id])
    disponibilidades = relationship("Disponibilidad", back_populates="recurso", cascade="all, delete-orphan")
    reservas = relationship("ReservaUsuario", back_populates="recurso", cascade="all, delete-orphan")
    amenidades = relationship("Amenidad", secondary=recurso_amenidades, back_populates="recursos")
    fotos = relationship("ImageRecurso", back_populates="recurso", cascade="all, delete-orphan")
    resenas = relationship("Resena", back_populates="recurso", cascade="all, delete-orphan")
    favoritos = relationship("User", secondary=user_favorites, back_populates="favoritos")

class Disponibilidad(Base):
    __tablename__ = "disponibilidad"
    id = Column(Integer, primary_key=True, index=True)
    recurso_id = Column(Integer, ForeignKey("recurso.id", ondelete="CASCADE"))
    fecha_inicio = Column(Date)
    fecha_fin = Column(Date)
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    cantidad_disponible = Column(Integer, default=1)  # si hay múltiples unidades
    precio_especial = Column(Float, nullable=True)  # para tarifas dinámicas
    es_disponible = Column(Boolean, default=True)
    
    recurso = relationship("Recurso", back_populates="disponibilidades")
    
class ReservaUsuario(Base):
    __tablename__ = "ReservaUsuario"
    id = Column(Integer, primary_key=True, index=True)
    recurso_id = Column(Integer, ForeignKey("recurso.id", ondelete="CASCADE"))
    usuario_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    fecha_inicio = Column(Date)
    fecha_fin = Column(Date)
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    cantidad = Column(Integer, default=1)
    precio_total = Column(Float)
    estado = Column(String(50), default="Pendiente")  # Pendiente, Confirmada, Cancelada, Completada
    notas = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    recurso = relationship("Recurso", back_populates="reservas")
    usuario = relationship("User", back_populates="reservas")
    pago = relationship("Pago", back_populates="reserva", uselist=False)

class Resena(Base):
    __tablename__ = "resena"
    id = Column(Integer, primary_key=True, index=True)
    recurso_id = Column(Integer, ForeignKey("recurso.id", ondelete="CASCADE"))
    usuario_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    calificacion = Column(Integer)  # 1-5
    comentario = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    recurso = relationship("Recurso", back_populates="resenas")
