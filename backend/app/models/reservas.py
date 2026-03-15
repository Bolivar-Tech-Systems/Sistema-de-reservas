from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey
from app.core.database import Base

class Reserva(Base):
    __tablename__ = "Reservas"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    owner_id = Column(Integer, ForeignKey("users.id"))

class Disponibilidad(Base):
    __tablename__ = "Disponibilidad"
    id = Column(Integer, primary_key=True, index=True)
    date = Column(Date)
    time = Column(Time)
    reserva_id = Column(Integer, ForeignKey("Reservas.id"))
    
class ReservaUsuario(Base):
    __tablename__ = "ReservaUsuario"
    id = Column(Integer, primary_key=True, index=True)
    reserva_id = Column(Integer, ForeignKey("Reservas.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    fecha_inicio = Column(Date)
    fecha_fin = Column(Date)
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    estado = Column(String, default="Pendiente")
