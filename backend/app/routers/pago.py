from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.pago import PagoCreate, PagoResponse
from app.services.pago import PagoService
from app.core.security import verify_token
from app.models.user import User

router = APIRouter(
    prefix="/pagos",
    tags=["Pagos"],
    dependencies=[Depends(verify_token)]
)

@router.post("/", response_model=PagoResponse)
def crear_pago(pago_in: PagoCreate, db: Session = Depends(get_db)):
    return PagoService.crear_pago(db, pago_in)

@router.get("/reserva/{reserva_id}", response_model=PagoResponse)
def obtener_pago_por_reserva(reserva_id: int, db: Session = Depends(get_db)):
    return PagoService.obtener_pago_por_reserva(db, reserva_id)

@router.post("/simular-wompi/{reserva_id}", response_model=PagoResponse)
def simular_pago_wompi(
    reserva_id: int, 
    referencia: str | None = "SIM-WOMPI-12345", 
    exitoso: bool = True,
    db: Session = Depends(get_db)
):
    estado = "Completado" if exitoso else "Fallido"
    return PagoService.actualizar_estado(db, reserva_id, estado, referencia)
