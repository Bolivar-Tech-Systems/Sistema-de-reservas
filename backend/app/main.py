from fastapi import FastAPI
from app.core.database import engine, Base
from app.routers import auth, reservas, images, roles, permisos, categorias
from fastapi.middleware.cors import CORSMiddleware

# Carga los modelos para que SQLAlchemy registre toda la metadata antes de create_all.
from app.models import user, reservas as reservas_model, images as images_model, permisos as permisos_model, categoria, amenidad, asociaciones, pago

# Crea las tablas en PostgreSQL
Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Routers
app.include_router(auth.router)
app.include_router(reservas.router)
app.include_router(images.router)
app.include_router(roles.router)
app.include_router(permisos.router)
app.include_router(categorias.router)

