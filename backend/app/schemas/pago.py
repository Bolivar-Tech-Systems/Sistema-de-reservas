from datetime import datetime

from pydantic import BaseModel, ConfigDict


class PagoCreate(BaseModel):
    reserva_id: int
    monto: float
    metodo_pago: str
    estado_pago: str = "Pendiente"
    referencia_transaccion: str | None = None


class PagoResponse(BaseModel):
    id: int
    reserva_id: int
    monto: float
    metodo_pago: str
    estado_pago: str
    referencia_transaccion: str | None = None
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)
