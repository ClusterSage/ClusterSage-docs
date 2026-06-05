from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.audit.service import write_audit
from app.auth.dependencies import get_current_user
from app.db.session import get_session
from app.models.entities import Cluster, ClusterSnapshot, Issue, LogBatch, User
from app.schemas.api import ClusterResponse, IssueResponse, LogBatchResponse, SnapshotResponse

router = APIRouter(prefix="/api/clusters", tags=["clusters"])

@router.get("", response_model=list[ClusterResponse])
async def clusters(user: User = Depends(get_current_user), session: AsyncSession = Depends(get_session)):
    return (await session.execute(select(Cluster).where(Cluster.organization_id == user.organization_id).order_by(Cluster.created_at.desc()))).scalars().all()

async def get_cluster(cluster_id: UUID, user: User, session: AsyncSession) -> Cluster:
    cluster = await session.get(Cluster, cluster_id)
    if not cluster or cluster.organization_id != user.organization_id:
        raise HTTPException(status_code=404, detail="Cluster not found")
    return cluster

@router.get("/{clusterId}", response_model=ClusterResponse)
async def cluster_detail(clusterId: UUID, user: User = Depends(get_current_user), session: AsyncSession = Depends(get_session)):
    return await get_cluster(clusterId, user, session)

@router.delete("/{clusterId}", status_code=204)
async def deactivate_cluster(clusterId: UUID, user: User = Depends(get_current_user), session: AsyncSession = Depends(get_session)):
    cluster = await get_cluster(clusterId, user, session)
    cluster.status = "deactivated"
    await write_audit(session, "cluster.deactivated", "user", user.organization_id, user.id, cluster.id, {"cluster_name": cluster.name})
    await session.commit()
    return None

@router.get("/{clusterId}/logs", response_model=list[LogBatchResponse])
async def cluster_logs(clusterId: UUID, user: User = Depends(get_current_user), session: AsyncSession = Depends(get_session)):
    await get_cluster(clusterId, user, session)
    return (await session.execute(select(LogBatch).where(LogBatch.cluster_id == clusterId).order_by(LogBatch.created_at.desc()).limit(100))).scalars().all()

@router.get("/{clusterId}/issues", response_model=list[IssueResponse])
async def cluster_issues(clusterId: UUID, user: User = Depends(get_current_user), session: AsyncSession = Depends(get_session)):
    await get_cluster(clusterId, user, session)
    return (await session.execute(select(Issue).where(Issue.cluster_id == clusterId).order_by(Issue.last_seen_at.desc()).limit(200))).scalars().all()

@router.get("/{clusterId}/snapshots/latest", response_model=SnapshotResponse | None)
async def latest_snapshot(clusterId: UUID, user: User = Depends(get_current_user), session: AsyncSession = Depends(get_session)):
    await get_cluster(clusterId, user, session)
    return (await session.execute(select(ClusterSnapshot).where(ClusterSnapshot.cluster_id == clusterId).order_by(ClusterSnapshot.created_at.desc()).limit(1))).scalars().first()
