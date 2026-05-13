from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.core.casbin_setup import enforcer
from app.routers.auth import get_current_user
from app.models.user import User

router = APIRouter(prefix="/casbin", tags=["casbin_policies"])

class PolicyModel(BaseModel):
    role: str
    resource: str
    action: str

@router.get("/policies")
def get_all_policies(current_user: User = Depends(get_current_user)):
    """
    Returns all policies defined in the database via Casbin adapter.
    """
    policies = enforcer.get_policy()
    return [{"role": p[0], "resource": p[1], "action": p[2]} for p in policies]

@router.post("/policies/add")
def add_policy(policy: PolicyModel, current_user: User = Depends(get_current_user)):
    """
    Adds a new policy rule.
    """
    success = enforcer.add_policy(policy.role, policy.resource, policy.action)
    if not success:
        raise HTTPException(status_code=400, detail="La política ya existe o no se pudo agregar.")
    return {"message": "Política agregada exitosamente"}

@router.post("/policies/remove")
def remove_policy(policy: PolicyModel, current_user: User = Depends(get_current_user)):
    """
    Removes a policy rule.
    """
    success = enforcer.remove_policy(policy.role, policy.resource, policy.action)
    if not success:
        raise HTTPException(status_code=400, detail="La política no existe o no se pudo eliminar.")
    return {"message": "Política eliminada exitosamente"}
