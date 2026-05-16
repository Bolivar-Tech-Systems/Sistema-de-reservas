from fastapi import FastAPI, Request
from app.core.database import engine, Base, audit_user_id, SessionLocal

# Carga los modelos para que SQLAlchemy registre toda la metadata antes de create_all.
from app.models import user, reservas as reservas_model, images as images_model, permisos as permisos_model, categoria, amenidad, asociaciones, pago
from sqlalchemy.orm import configure_mappers

# Configurar mappers para sqlalchemy-continuum
configure_mappers()

from app.routers import auth, reservas, images, roles, permisos, categorias, audit, casbin_policies, notificaciones
from fastapi.middleware.cors import CORSMiddleware
from app.core.security import verify_token
from app.models.user import User
from fastapi_audit_log import AuditLogger
from app.core.config import DATABASE_URL

# Crea las tablas en PostgreSQL
Base.metadata.create_all(bind=engine)

app = FastAPI()

origins = [
    "https://129-80-171-141.nip.io",
    "http://129-80-171-141.nip.io",
    "http://localhost:5173",
    "http://localhost:4173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
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
