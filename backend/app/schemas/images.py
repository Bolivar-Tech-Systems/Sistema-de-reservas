from pydantic import BaseModel, ConfigDict


class ImageCreate(BaseModel):
    file_name: str


class ImageProfileCreate(BaseModel):
    owner_id: int
    url_image_profile: str


class ImageProfileResponse(ImageProfileCreate):
    id: int

    model_config = ConfigDict(from_attributes=True)


class ImageRecursoCreate(BaseModel):
    recurso_id: int
    url: str
    orden: int = 0


class ImageResponse(ImageRecursoCreate):
    id: int

    model_config = ConfigDict(from_attributes=True)

    @property
    def url_image_reserva(self) -> str:
        return self.url
