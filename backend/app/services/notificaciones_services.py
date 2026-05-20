import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import HTTPException
from datetime import datetime
import os
from dotenv import load_dotenv
import json

load_dotenv()

if not firebase_admin._apps:
    creds_json = os.getenv("FIREBASE_CREDENTIALS_JSON")
    if creds_json:
        cred = credentials.Certificate(json.loads(creds_json))
    else:
        raise Exception("FIREBASE_CREDENTIALS_JSON no está definido en el .env")
    firebase_admin.initialize_app(cred)


db = firestore.client()
COLLECTION = "notificaciones"


def crear_notificacion(id_usuario: str, titulo: str, mensaje: str, tipo: str):
    """Crea una notificación para un usuario específico."""
    try:
        db.collection(COLLECTION).add({
            "id_usuario": id_usuario,
            "titulo": titulo,
            "mensaje": mensaje,
            "tipo": tipo,
            "leida": False,
            "fecha": datetime.utcnow(),
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def enviar_a_todos(usuarios: list, titulo: str, mensaje: str, tipo: str):
    """Envía la misma notificación a una lista de usuarios."""
    try:
        for user_id in usuarios:
            crear_notificacion(
                id_usuario=str(user_id),
                titulo=titulo,
                mensaje=mensaje,
                tipo=tipo,
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def listar_todas():
    """Lista todas las notificaciones ordenadas por fecha descendente."""
    try:
        docs = db.collection(COLLECTION).order_by("fecha", direction=firestore.Query.DESCENDING).stream()
        resultado = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            if data.get("fecha"):
                data["fecha"] = data["fecha"].isoformat() if hasattr(data["fecha"], "isoformat") else str(data["fecha"])
            resultado.append(data)
        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def listar_por_usuario(id_usuario: str):
    """Lista las notificaciones de un usuario específico."""
    try:
        docs = (
            db.collection(COLLECTION)
            .where("id_usuario", "==", id_usuario)
            .order_by("fecha", direction=firestore.Query.DESCENDING)
            .stream()
        )
        resultado = []
        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id
            if data.get("fecha"):
                data["fecha"] = data["fecha"].isoformat() if hasattr(data["fecha"], "isoformat") else str(data["fecha"])
            resultado.append(data)
        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def marcar_leida(doc_id: str):
    """Marca una notificación como leída."""
    try:
        db.collection(COLLECTION).document(doc_id).update({"leida": True})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def marcar_todas_leidas(id_usuario: str):
    """Marca todas las notificaciones de un usuario como leídas."""
    try:
        docs = (
            db.collection(COLLECTION)
            .where("id_usuario", "==", id_usuario)
            .where("leida", "==", False)
            .stream()
        )
        for doc in docs:
            doc.reference.update({"leida": True})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def eliminar_notificacion(doc_id: str):
    """Elimina una notificación de Firestore."""
    try:
        db.collection(COLLECTION).document(doc_id).delete()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))