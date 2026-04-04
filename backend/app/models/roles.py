from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey
from app.core.database import Base

class Role(Base):
    __tablename__ = "roles"
    id = Column(Integer, primary_key=True, index=True)
    name_rol = Column(String, unique=True, index=True, default="user")
    description = Column(String)