from fastapi import FastAPI, Request
from app.core.database import engine, Base, audit_user_id, SessionLocal

# Carga los modelos para que SQLAlchemy registre toda la metadata antes de create_all.
from app.models import user, reservas as reservas_model, images as images_model, permisos as permisos_model, categoria, amenidad, asociaciones, pago
from sqlalchemy.orm import configure_mappers

# Configurar mappers para sqlalchemy-continuum
configure_mappers()

from app.routers import auth, reservas, images, roles, permisos, categorias, audit, casbin_policies, notificaciones, amenidades, resenas, favoritos, pago
from fastapi.middleware.cors import CORSMiddleware
from app.core.security import verify_token
from app.models.user import User
from fastapi_audit_log import AuditLogger
from app.core.config import DATABASE_URL

# Crea las tablas en PostgreSQL
Base.metadata.create_all(bind=engine)

from fastapi.staticfiles import StaticFiles
import os

app = FastAPI()

# Asegurar directorios locales para uploads fallback
os.makedirs("static/uploads/profiles", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.on_event("startup")
def seed_categories():
    db = SessionLocal()
    try:
        from app.models.categoria import Categoria
        count = db.query(Categoria).count()
        if count == 0:
            default_categories = [
                {"nombre": "Sala de Reuniones", "descripcion": "Salas equipadas para juntas y conferencias", "icono": "meeting_room"},
                {"nombre": "Auditorio", "descripcion": "Espacios amplios para conferencias y eventos", "icono": "theater_comedy"},
                {"nombre": "Cancha", "descripcion": "Instalaciones deportivas para recreación", "icono": "sports_soccer"},
                {"nombre": "Oficina", "descripcion": "Espacios individuales y coworking", "icono": "work"},
                {"nombre": "Laboratorio", "descripcion": "Instalaciones especializadas para experimentación", "icono": "science"},
            ]
            for cat_data in default_categories:
                cat = Categoria(
                    nombre=cat_data["nombre"],
                    descripcion=cat_data["descripcion"],
                    icono=cat_data["icono"]
                )
                db.add(cat)
            db.commit()
            print("Categorias sembradas en la db.")
    except Exception as e:
        db.rollback()
        print(f"Error al sembrar categorias: {e}")
    finally:
        db.close()

origins = [
    "https://129-80-171-141.nip.io",
    "http://129-80-171-141.nip.io",
    "http://localhost:5173",
    "http://localhost:4173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def audit_user_middleware(request: Request, call_next):
    # Intentar extraer el usuario del token para la auditoría de continuum
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        token = auth_header.split(" ")[1]
        email = verify_token(token)
        if email:
            db = SessionLocal()
            try:
                db_user = db.query(User).filter(User.email == email).first()
                if db_user:
                    audit_user_id.set(db_user.id)
            finally:
                db.close()
    
    response = await call_next(request)
    return response

# Configurar fastapi-audit-log
AuditLogger(
    app,
    db_url=DATABASE_URL,
    table_name="audit_log",
)

# Routers
app.include_router(auth.router)
app.include_router(reservas.router)
app.include_router(images.router)
app.include_router(roles.router)
app.include_router(permisos.router)
app.include_router(categorias.router)
app.include_router(audit.router)
app.include_router(casbin_policies.router)
app.include_router(notificaciones.router)
app.include_router(amenidades.router)
app.include_router(resenas.router)
app.include_router(favoritos.router)
app.include_router(pago.router)

