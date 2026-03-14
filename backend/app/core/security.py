from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from app.core.config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, FORGET_PWD_SECRET_KEY

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            return None
        return email
    except JWTError:
        return None
def create_reset_password_token (email: str):
     data = {"sub":email, "exp": datetime.utcnow() + timedelta(minutes = 10)}
     token = jwt.encode(data,FORGET_PWD_SECRET_KEY, ALGORITHM)
     return token