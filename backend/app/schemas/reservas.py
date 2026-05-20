from datetime import date, datetime, time

from pydantic import BaseModel, ConfigDict, Field


class RecursoBase(BaseModel):
    nombre: str = Field(alias="name")
    descripcion: str | None = Field(default=None, alias="description")
    precio_por_hora: float | None = None
    foto_principal: str | None = None
    categoria_id: int | None = None
    capacidad: int | None = None
    es_visible: bool = True

    model_config = ConfigDict(populate_by_name=True)

    @property
    def name(self) -> str:
        return self.nombre

    @property
    def description(self) -> str | None:
        return self.descripcion


class RecursoCreate(RecursoBase):
    pass


from app.schemas.images import ImageResponse
from app.schemas.amenidad import AmenidadResponse

class RecursoResponse(RecursoBase):
    id: int
    owner_id: int
    calificacion_promedio: float | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    fotos: list[ImageResponse] = []
    amenidades: list[AmenidadResponse] = []

    model_config = ConfigDict(from_attributes=True)


class DisponibilidadBase(BaseModel):
    recurso_id: int = Field(alias="reserva_id")
    fecha_inicio: date
    fecha_fin: date
    hora_inicio: time
    hora_fin: time
    cantidad_disponible: int = 1
    precio_especial: float | None = None
    es_disponible: bool = True

    model_config = ConfigDict(populate_by_name=True)

    @property
    def reserva_id(self) -> int:
        return self.recurso_id


class DisponibilidadCreate(DisponibilidadBase):
    pass


class DisponibilidadResponse(DisponibilidadBase):
    id: int

    model_config = ConfigDict(from_attributes=True)


class ReservaUsuarioBase(BaseModel):
    recurso_id: int = Field(alias="reserva_id")
    fecha_inicio: date
    fecha_fin: date
    hora_inicio: time
    hora_fin: time
    cantidad: int = 1
    precio_total: float | None = None
    estado: str = "Pendiente"
    notas: str | None = None

    model_config = ConfigDict(populate_by_name=True)

    @property
    def reserva_id(self) -> int:
        return self.recurso_id


class ReservaUsuarioCreate(ReservaUsuarioBase):
    pass


class ReservaUsuarioResponse(ReservaUsuarioBase):
    id: int
    usuario_id: int
    created_at: datetime | None = None
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)

    @property
    def user_id(self) -> int:
        return self.usuario_id


class ResenaCreate(BaseModel):
    recurso_id: int
    usuario_id: int
    calificacion: int
    comentario: str | None = None

    model_config = ConfigDict(from_attributes=True)


class UserMinResponse(BaseModel):
    id: int
    nombre: str | None = Field(None, alias="name")

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )


class ResenaResponse(ResenaCreate):
    id: int
    created_at: datetime | None = None
    usuario: UserMinResponse | None = None

    model_config = ConfigDict(from_attributes=True)
