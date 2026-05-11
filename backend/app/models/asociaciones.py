from sqlalchemy import Table, Column, Integer, ForeignKey
from app.core.database import Base

user_favorites = Table(
    'user_favorites',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id', ondelete="CASCADE")),
    Column('recurso_id', Integer, ForeignKey('recurso.id', ondelete="CASCADE"))
)

recurso_amenidades = Table(
    'recurso_amenidades',
    Base.metadata,
    Column('recurso_id', Integer, ForeignKey('recurso.id', ondelete="CASCADE")),
    Column('amenidad_id', Integer, ForeignKey('amenidad.id', ondelete="CASCADE"))
)