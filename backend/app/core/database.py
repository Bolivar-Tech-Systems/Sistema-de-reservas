from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy_continuum import make_versioned
from sqlalchemy_continuum.plugins import Plugin
import contextvars

from app.core.config import DATABASE_URL

audit_user_id = contextvars.ContextVar("audit_user_id", default=None)

class FastAPIUserPlugin(Plugin):
    def transaction_before_create(self, session, transaction):
        user_id = audit_user_id.get()
        if user_id is not None:
            transaction.user_id = str(user_id) # Set user_id if string or integer depending on config

make_versioned(user_cls='User', plugins=[FastAPIUserPlugin()])

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()