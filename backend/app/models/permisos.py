from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey
from app.core.database import Base

class Permiso(Base):
    __tablename__ = "Permisos"
    id = Column(Integer, primary_key=True, index=True)
    name_permiso = Column(String, unique=True, index=True)
    description = Column(String)
    
class PermisoRole(Base):
    __tablename__ = "PermisoRole"
    id = Column(Integer, primary_key=True, index=True)
    permiso_id = Column(Integer, ForeignKey("Permisos.id"))
    role_id = Column(Integer, ForeignKey("roles.id"))