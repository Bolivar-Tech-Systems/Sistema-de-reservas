from pydantic import BaseModel, ConfigDict


class RoleCreate(BaseModel):
    name_rol: str
    description: str | None = None


class RoleResponse(BaseModel):
    id: int
    name_rol: str
    description: str | None = None

    model_config = ConfigDict(from_attributes=True)
