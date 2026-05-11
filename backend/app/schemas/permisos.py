from pydantic import BaseModel, ConfigDict


class PermisoCreate(BaseModel):
    name_permiso: str
    description: str | None = None


class PermisoResponse(BaseModel):
    id: int
    name_permiso: str
    description: str | None = None

    model_config = ConfigDict(from_attributes=True)


class PermisoRoleAssing(BaseModel):
    permiso_id: int
    role_id: int


class PermisoRoleResponse(BaseModel):
    id: int
    permiso_id: int
    role_id: int

    model_config = ConfigDict(from_attributes=True)
