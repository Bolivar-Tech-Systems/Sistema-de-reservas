import os

try:
    from fastapi_mail import ConnectionConfig
except ImportError:
    ConnectionConfig = None

if ConnectionConfig is not None:
    mail_port = os.getenv("MAIL_PORT")
    mail_conf = ConnectionConfig(
        MAIL_USERNAME=os.getenv("MAIL_USERNAME"),
        MAIL_PASSWORD=os.getenv("MAIL_PASSWORD"),
        MAIL_FROM=os.getenv("MAIL_FROM"),
        MAIL_PORT=int(mail_port) if mail_port else 0,
        MAIL_SERVER=os.getenv("MAIL_SERVER"),
        MAIL_STARTTLS=True,
        MAIL_SSL_TLS=False,
        USE_CREDENTIALS=True,
        VALIDATE_CERTS=True,
        TEMPLATE_FOLDER="app/templates",
    )
else:
    mail_conf = None
