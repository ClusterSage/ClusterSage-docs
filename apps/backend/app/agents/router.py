from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.audit.service import write_audit
from app.auth.dependencies import get_current_agent
from app.auth.security import create_agent_token, verify_secret
from app.db.session import get_session
from app.models.entities import AgentKey, Cluster, User
from app.schemas.api import AgentRegisterRequest, AgentRegisterResponse, HeartbeatRequest

router = APIRouter(prefix="/api/agent", tags=["agent"])

@router.post("/register", response_model=AgentRegisterResponse)
async def register_agent(payload: AgentRegisterRequest, session: AsyncSession = Depends(get_session)):
    user = (await session.execute(select(User).where(User.email == payload.email.lower()))).scalars().first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid agent credentials")
    keys = (await session.execute(select(AgentKey).where(AgentKey.organization_id == user.organization_id, AgentKey.revoked_at.is_(None)))).scalars().all()
    now = datetime.now(timezone.utc)
    valid = next((key for key in keys if (key.expires_at is None or key.expires_at > now) and verify_secret(payload.access_key, key.key_hash)), None)
    if not valid:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid agent credentials")
    cluster = (await session.execute(select(Cluster).where(Cluster.organization_id == user.organization_id, Cluster.name == payload.cluster_name))).scalars().first()
    if not cluster:
        cluster = Cluster(organization_id=user.organization_id, name=payload.cluster_name, provider=payload.provider, kube_system_uid=payload.kube_system_uid, agent_version=payload.agent_version, status="connected", last_seen_at=now)
        session.add(cluster)
        await session.flush()
    else:
        cluster.provider = payload.provider
        cluster.kube_system_uid = payload.kube_system_uid or cluster.kube_system_uid
        cluster.agent_version = payload.agent_version
        cluster.status = "connected"
        cluster.last_seen_at = now
    await write_audit(session, "agent.registration", "agent", user.organization_id, cluster_id=cluster.id, details={"cluster_name": cluster.name, "key_last4": valid.key_last4})
    await session.commit()
    return AgentRegisterResponse(cluster_id=cluster.id, agent_token=create_agent_token(str(cluster.id), str(user.organization_id)))

@router.post("/heartbeat")
async def heartbeat(payload: HeartbeatRequest, cluster: Cluster = Depends(get_current_agent), session: AsyncSession = Depends(get_session)):
    cluster.status = payload.status or "healthy"
    cluster.agent_version = payload.agent_version or cluster.agent_version
    cluster.last_seen_at = datetime.now(timezone.utc)
    await write_audit(session, "cluster.heartbeat", "agent", cluster.organization_id, cluster_id=cluster.id, details={"status": cluster.status})
    await session.commit()
    return {"ok": True, "cluster_id": str(cluster.id)}
