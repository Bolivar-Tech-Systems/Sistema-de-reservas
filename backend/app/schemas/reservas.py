from pydantic import BaseModel
from datetime import date, time

class ReservaCreate(BaseModel):
    name: str
    description: str

class ReservaResponse(BaseModel):
    id: int
    name: str
    description: str
    owner_id: int

    class Config:
        from_attributes = True

class DisponibilidadCreate(BaseModel):
    date: date    
    time: time   
    reserva_id: int

class DisponibilidadResponse(BaseModel):
    id: int
    date: date
    time: time
    reserva_id: int

    class Config:
        from_attributes = True

class ReservaUsuarioCreate(BaseModel):
    reserva_id: int
    fecha_inicio: date
    fecha_fin: date

class ReservaUsuarioResponse(BaseModel):
    id: int
    reserva_id: int
    user_id: int
    fecha_inicio: date
    fecha_fin: date
    estado: str

    class Config:
        from_attributes = True