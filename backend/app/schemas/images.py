from pydantic import BaseModel

class ImageCreate(BaseModel):
    file_name: str

class ImageResponse(BaseModel):
    id: int
    url_image_reserva: str
    
    class Config:
        from_attributes = True