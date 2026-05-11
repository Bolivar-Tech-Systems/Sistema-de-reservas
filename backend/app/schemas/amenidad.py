from pydantic import BaseModel, ConfigDict


class AmenidadCreate(BaseModel):
    nombre: str
    icono: str | None = None


class AmenidadResponse(BaseModel):
    id: int
    nombre: str
    icono: str | None = None

    model_config = ConfigDict(from_attributes=True)
