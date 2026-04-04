from pydantic import BaseModel

class PermisoCreate(BaseModel):
    name_permiso: str
    description: str = None
    
class PermisoResponse(BaseModel):
    id: int
    name_permiso: str
    description: str = None
    
    class Config:
        from_attributes = True

class PermisoRoleAssing(BaseModel):
    name_permiso: str
    description: str = None
    role_id: int
    permiso_id: int
    
class PermisoRoleResponse(BaseModel):
    id: int
    name_permiso: str
    description_permiso: str = None
    role_id: int
    permiso_id: int
    
    class Config:
        from_attributes = True
        