import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import os

# Inicializar solo si no está inicializado
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

def crear_notificacion(id_usuario: str, titulo: str, mensaje: str, tipo: str):
    db.collection("notificaciones").add({
        "id_usuario": id_usuario,
        "titulo": titulo,
        "mensaje": mensaje,
        "tipo": tipo,
        "leida": False,
        "fecha": datetime.utcnow(),
    })