from fastapi import FastAPI
from app.core.database import engine, Base
from app.routers import auth

# Crea las tablas en PostgreSQL
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Routers
app.include_router(auth.router)