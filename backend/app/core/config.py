from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from dotenv import load_dotenv
import os

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES"))

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
SUPABASE_BUCKET_NAME = os.getenv("SUPABASE_BUCKET_NAME")
#No lo estoy usando porque esto para cuando necesitamos que sea privado, pero lo dejo por si escala la aplicacion y necesitamos que las imagenes sean privadas
SUPABASE_API_KEY_ADMIN = os.getenv("SUPABASE_API_KEY_ADMIN")


SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
SUPABASE_BUCKET_NAME = os.getenv("SUPABASE_BUCKET_NAME")
#No lo estoy usando porque esto para cuando necesitamos que sea privado, pero lo dejo por si escala la aplicacion y necesitamos que las imagenes sean privadas
SUPABASE_API_KEY_ADMIN = os.getenv("SUPABASE_API_KEY_ADMIN")


APP_HOST = os.getenv("APP_HOST")
FORGET_PASSWORD_URL = os.getenv("FORGET_PASSWORD_URL")
FORGET_PASSWORD_LINK_EXPIRE_MINUTES = int(os.getenv("FORGET_PASSWORD_LINK_EXPIRE_MINUTES"))
MAIL_FROM_NAME = os.getenv("MAIL_FROM_NAME")
FORGET_PWD_SECRET_KEY = os.getenv("FORGET_PWD_SECRET_KEY")
