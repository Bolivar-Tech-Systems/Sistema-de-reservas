from sqlalchemy.orm import Session
from app.models.pago import Pago
from app.models.reservas import ReservaUsuario
from app.schemas.pago import PagoCreate
from fastapi import HTTPException, status

class PagoService:
    @staticmethod
    def crear_pago(db: Session, pago_in: PagoCreate) -> Pago:
        # Verificar que la reserva existe
        reserva = db.query(ReservaUsuario).filter(ReservaUsuario.id == pago_in.reserva_id).first()
        if not reserva:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="La reserva no existe"
            )
        
        # Verificar si ya existe un pago para esta reserva
        pago_existente = db.query(Pago).filter(Pago.reserva_id == pago_in.reserva_id).first()
        if pago_existente:
            return pago_existente

        db_pago = Pago(
            reserva_id=pago_in.reserva_id,
            monto=pago_in.monto,
            metodo_pago=pago_in.metodo_pago,
            estado_pago=pago_in.estado_pago,
            referencia_transaccion=pago_in.referencia_transaccion
        )
        db.add(db_pago)
        db.commit()
        db.refresh(db_pago)
        return db_pago

    @staticmethod
    def obtener_pago(db: Session, pago_id: int) -> Pago:
        pago = db.query(Pago).filter(Pago.id == pago_id).first()
        if not pago:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pago no encontrado"
            )
        return pago

    @staticmethod
    def obtener_pago_por_reserva(db: Session, reserva_id: int) -> Pago:
        pago = db.query(Pago).filter(Pago.reserva_id == reserva_id).first()
        if not pago:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pago no encontrado para esta reserva"
            )
        return pago

    @staticmethod
    def actualizar_estado(db: Session, reserva_id: int, estado: str, referencia: str = None) -> Pago:
        pago = db.query(Pago).filter(Pago.reserva_id == reserva_id).first()
        if not pago:
            raise HTTPException(
                status_code=status.HTTP_444_NOT_FOUND,
                detail="Pago no encontrado"
            )
        pago.estado_pago = estado
        if referencia:
            pago.referencia_transaccion = referencia
        
        # Si el pago se completa, podríamos actualizar el estado de la reserva a "Confirmada"
        if estado == "Completado":
            reserva = db.query(ReservaUsuario).filter(ReservaUsuario.id == reserva_id).first()
            if reserva:
                reserva.estado = "Confirmada"

        db.commit()
        db.refresh(pago)
        return pago
