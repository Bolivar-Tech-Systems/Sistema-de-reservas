from pydantic import BaseModel


class NotificacionCreate(BaseModel):
    id_usuario: int
    titulo: str
    mensaje: str
    tipo: str = "general"


class NotificacionMasiva(BaseModel):
    titulo: str
    mensaje: str
    tipo: str = "general"
