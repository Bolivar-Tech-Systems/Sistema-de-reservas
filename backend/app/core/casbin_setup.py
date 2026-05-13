import casbin
import os
from casbin_sqlalchemy_adapter import Adapter
from sqlalchemy import create_engine
from app.core.config import DATABASE_URL

# Path to the RBAC model configuration
MODEL_PATH = os.path.join(os.path.dirname(__file__), "rbac_model.conf")

engine = create_engine(DATABASE_URL)
adapter = Adapter(engine)

def get_enforcer():
    enforcer = casbin.Enforcer(MODEL_PATH, adapter)
    return enforcer

enforcer = get_enforcer()
