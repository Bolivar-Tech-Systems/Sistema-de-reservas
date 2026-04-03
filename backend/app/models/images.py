from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey
from app.core.database import Base

class ImageProfile(Base):
    __tablename__ = "ImageProfile"
    id = Column(Integer, primary_key=True, index=True)
    url_image_profile = Column(String)
    owner_id = Column(Integer, ForeignKey("users.id"))

class ImageReserva(Base):
    __tablename__ = "ImageReserva"
    id = Column(Integer, primary_key=True, index=True)
    url_image_reserva = Column(String)
    file_name = Column(String)
    reserva_id = Column(Integer, ForeignKey("Reservas.id"))
