from fastapi import FastAPI
from app.core.database import engine, Base
from app.routers import auth, reservas, images
from fastapi.middleware.cors import CORSMiddleware
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

