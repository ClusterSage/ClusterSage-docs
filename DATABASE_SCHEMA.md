# Database Schema

The Alembic migration is `repos/ClusterSage-services/services/platform-api/alembic/versions/0001_initial.py`.

## Tables

- `organizations`: `id`, `name`, `created_at`, `updated_at`.
- `users`: `id`, `organization_id`, `email`, `password_hash`, `full_name`, `role`, timestamps.
- `agent_keys`: `id`, `organization_id`, `created_by_user_id`, `name`, `key_hash`, `key_last4`, `expires_at`, `revoked_at`, `created_at`.
- `clusters`: `id`, `organization_id`, `name`, `provider`, `kube_system_uid`, `agent_version`, `status`, `last_seen_at`, timestamps.
- `log_batches`: `id`, `organization_id`, `cluster_id`, `blob_path`, `log_count`, `size_bytes`, `start_time`, `end_time`, `created_at`.
- `cluster_snapshots`: `id`, `organization_id`, `cluster_id`, `snapshot_type`, `blob_path`, `created_at`.
- `issues`: `id`, `organization_id`, `cluster_id`, Kubernetes context fields, severity, type, title, description, status, timestamps.
- `ai_recommendations`: `id`, `organization_id`, `cluster_id`, optional `issue_id`, `recommendation_json`, `created_at`.
- `audit_logs`: `id`, optional org/user/cluster links, action, actor type, JSON details, `created_at`.
- `ai_log_findings`: additive Phase 1 table for pre-classified log evidence and signature grouping.
- `ai_incidents`: additive Phase 1 table for richer pod/workload/cluster incident records, separate from the current `issues` table.
- `remediation_suggestions`: additive Phase 1 table for AI-generated or deterministic remediation guidance.
- `remediation_approvals`: additive Phase 1 table for explicit user approval state.
- `remediation_actions`: additive Phase 1 table for approved executable actions such as rollout restart.
- `ai_cluster_queries`: additive Phase 1 table for natural-language cluster query history.
- `alert_limits`: additive Phase 3 table for cluster-scoped alert threshold definitions, notification target settings, cooldown, and enabled/disabled state.
- `alert_events`: additive Phase 3 table for alert trigger history and notification-send outcome tracking.

## Run Migrations

```bash
cd repos/ClusterSage-services/services/platform-api
alembic upgrade head
```

With Docker Compose:

```bash
docker compose exec backend alembic upgrade head
```

Note: Phase 1 added `0002_ai_incidents_and_remediation.py`. Phase 3 added `0003_alert_limits.py`. These migrations are additive and do not remove or rewrite existing tables.

## Useful Checks

```sql
SELECT * FROM organizations;
SELECT * FROM users;
SELECT * FROM agent_keys;
SELECT * FROM clusters;
SELECT * FROM log_batches;
SELECT * FROM issues;
```
