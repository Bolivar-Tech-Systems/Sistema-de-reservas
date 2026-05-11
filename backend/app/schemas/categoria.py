from pydantic import BaseModel, ConfigDict


class CategoriaCreate(BaseModel):
    nombre: str
    descripcion: str | None = None
    icono: str | None = None


class CategoriaResponse(BaseModel):
    id: int
    nombre: str
    descripcion: str | None = None
    icono: str | None = None

    model_config = ConfigDict(from_attributes=True)
