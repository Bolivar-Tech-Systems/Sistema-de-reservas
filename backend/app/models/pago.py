from datetime import datetime
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Float
from sqlalchemy.orm import relationship
from app.core.database import Base

class Pago(Base):
    __tablename__ = "pago"
    id = Column(Integer, primary_key=True, index=True)
    reserva_id = Column(Integer, ForeignKey("ReservaUsuario.id", ondelete="CASCADE"), unique=True)
    monto = Column(Float)
    metodo_pago = Column(String(50))  # tarjeta, transferencia, etc
    estado_pago = Column(String(50), default="Pendiente")  # Pendiente, Completado, Fallido
    referencia_transaccion = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    reserva = relationship("ReservaUsuario", back_populates="pago")

