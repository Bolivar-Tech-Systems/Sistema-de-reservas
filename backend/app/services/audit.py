from sqlalchemy.orm import Session
from fastapi_audit_log.models import Base

def get_audit_log_model():
    for mapper in Base.registry.mappers:
        if mapper.class_.__name__ == "AuditLog":
            return mapper.class_
    return None

def get_http_logs(db: Session, skip: int = 0, limit: int = 100):
    AuditLog = get_audit_log_model()
    if not AuditLog:
        return []
    return db.query(AuditLog).order_by(AuditLog.timestamp.desc()).offset(skip).limit(limit).all()

def get_model_history(db: Session, model_class, record_id: int):
    # Continuum version model
    VersionModel = model_class.__versioned__['class']
    versions = db.query(VersionModel).filter_by(id=record_id).all()
    
    result = []
    for v in versions:
        result.append({
            "transaction_id": v.transaction_id,
            "operation_type": v.operation_type,
            "changes": {
                # Aquí se podrían serializar los campos que cambiaron si se necesitan
                # En sqlalchemy-continuum los atributos del modelo están en el objeto version
                k: getattr(v, k) for k in v.__mapper__.columns.keys()
                if k not in ['transaction_id', 'end_transaction_id', 'operation_type']
            }
        })
    return result
