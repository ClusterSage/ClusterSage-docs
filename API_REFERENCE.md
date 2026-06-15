# API Reference

OpenAPI docs are available at `/docs` and `/openapi.json`.

## Public

- `GET /health` returns service health.

## Authenticated User Endpoints

Use `Authorization: Bearer <jwt>`.

- `POST /api/auth/register`: create organization and owner user.
- `POST /api/auth/login`: exchange email and password for JWT.
- `GET /api/auth/me`: return current user.
- `POST /api/agent-keys`: create an agent access key; raw key appears once.
- `GET /api/agent-keys`: list hashed-key metadata.
- `DELETE /api/agent-keys/{keyId}`: revoke an agent key.
- `GET /api/clusters`: list organization clusters.
- `GET /api/clusters/{clusterId}`: cluster details.
- `GET /api/clusters/{clusterId}/logs`: log batch indexes.
- `GET /api/clusters/{clusterId}/resources`: tenant-scoped resources from the latest cluster snapshot.
- `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}`: selected resource details.
- `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}/logs`: selected pod log lines from recent log batches.
- `GET /api/clusters/{clusterId}/issues`: detected issues.
- `GET /api/clusters/{clusterId}/snapshots/latest`: latest snapshot index.
- `GET /api/audit-logs`: recent tenant audit logs.

## Agent Endpoints

- `POST /api/agent/register`: send email, access key, cluster name, provider, and agent version. Returns `cluster_id` and `agent_token`.
- `POST /api/agent/heartbeat`: agent-token protected heartbeat.
- `POST /api/ingest/logs`: agent-token protected log ingestion, supports gzip request body.
- `POST /api/ingest/events`: agent-token protected event ingestion, supports gzip request body.
- `POST /api/ingest/snapshot`: agent-token protected snapshot ingestion, supports gzip request body.
