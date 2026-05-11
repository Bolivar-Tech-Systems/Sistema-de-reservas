from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class ImageProfile(Base):
    __tablename__ = "ImageProfile"
    id = Column(Integer, primary_key=True, index=True)
    url_image_profile = Column(String)
    owner_id = Column(Integer, ForeignKey("users.id"))

class ImageRecurso(Base):
    __tablename__ = "ImageRecurso"
    id = Column(Integer, primary_key=True, index=True)
    recurso_id = Column(Integer, ForeignKey("recurso.id", ondelete="CASCADE"))
    url = Column(String)
    orden = Column(Integer, default=0)
    
    recurso = relationship("Recurso", back_populates="fotos")