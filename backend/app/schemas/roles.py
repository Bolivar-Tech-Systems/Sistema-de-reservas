from pydantic import BaseModel

class RoleCreate(BaseModel):
    name_rol: str
    description: str = None
    user_id: int
    
    
class RoleResponse(BaseModel):
    id: int
    name_rol: str
    description: str = None
    user_id: int
     
    class Config:
        form_attributes = True