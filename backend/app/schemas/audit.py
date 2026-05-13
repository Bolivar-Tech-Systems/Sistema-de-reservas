from pydantic import BaseModel
from typing import Optional, Any
from datetime import datetime

class AuditLogResponse(BaseModel):
    id: int
    timestamp: datetime
    method: Optional[str]
    path: Optional[str]
    status_code: Optional[int]
    ip_address: Optional[str]
    request_body: Optional[str]
    response_body: Optional[str]
    duration_ms: Optional[float]

    class Config:
        from_attributes = True

class HistoryVersionResponse(BaseModel):
    transaction_id: int
    operation_type: int
    changes: Any

    class Config:
        from_attributes = True
