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
- `DELETE /api/clusters/{clusterId}`: permanently remove a connected cluster and delete its associated database records for that cluster.
- `GET /api/clusters/{clusterId}/logs`: log batch indexes.
- `POST /api/clusters/{clusterId}/ai/chat`: send a cluster-scoped investigation message and receive a grounded assistant response.
- `GET /api/clusters/{clusterId}/ai/conversations`: list bounded conversation history for the current user and selected cluster.
- `GET /api/clusters/{clusterId}/ai/conversations/{conversationId}`: retrieve one conversation plus stored messages.
- `POST /api/clusters/{clusterId}/ai/query`: legacy rule-based cluster query endpoint kept for backward compatibility.
- `GET /api/clusters/{clusterId}/resources`: tenant-scoped resources from the latest cluster snapshot.
- `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}`: selected resource details.
- `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}/logs`: selected pod log lines from recent log batches.
- `GET /api/clusters/{clusterId}/issues`: detected issues.
- `GET /api/clusters/{clusterId}/snapshots/latest`: latest snapshot index.
- `GET /api/clusters/{clusterId}/metrics/overview`: existing latest-slice CPU/memory overview for the current dashboard.
- `GET /api/clusters/{clusterId}/metrics/catalog`: latest-slice metrics filter catalog for nodes, namespaces, workloads, pods, metric names, and scopes.
- `GET /api/clusters/{clusterId}/metrics/latest`: filtered latest-slice metric breakdown for a selected metric name.
- `GET /api/clusters/{clusterId}/metrics/timeseries`: historical filtered timeseries for a selected metric name and window.
- `GET /api/clusters/{clusterId}/limits`: list alert limit definitions for the selected cluster.
- `POST /api/clusters/{clusterId}/limits`: create a cluster alert limit definition.
- `PATCH /api/clusters/{clusterId}/limits/{limitId}`: update a cluster alert limit definition.
- `POST /api/clusters/{clusterId}/limits/{limitId}/enable`: enable an alert limit definition.
- `POST /api/clusters/{clusterId}/limits/{limitId}/disable`: disable an alert limit definition.
- `DELETE /api/clusters/{clusterId}/limits/{limitId}`: delete an alert limit definition.
- `GET /api/clusters/{clusterId}/alert-events`: list stored alert events for the selected cluster.
- `GET /api/audit-logs`: recent tenant audit logs.

Current note:

- Alert limit CRUD exists.
- Automatic alert evaluation exists behind `ALERT_EVALUATION_ENABLED`.
- Alert-threshold emails are queued through Service Bus and sent by the email worker.
- `GET /api/clusters/{clusterId}/alert-events` returns stored breach rows; `notification_sent` currently reflects successful queue dispatch.
- The new conversation-based AI assistant is controlled separately by `AI_AGENT_ENABLED`.
- The assistant is read-only and uses bounded server-executed tools; it does not execute raw SQL, arbitrary shell commands, `kubectl`, or Kubernetes mutations.

## Agent Endpoints

- `POST /api/agent/register`: send email, access key, cluster name, provider, and agent version. Returns `cluster_id` and `agent_token`.
- `POST /api/agent/heartbeat`: agent-token protected heartbeat.
- `POST /api/ingest/logs`: agent-token protected log ingestion, supports gzip request body.
- `POST /api/ingest/events`: agent-token protected event ingestion, supports gzip request body.
- `POST /api/ingest/snapshot`: agent-token protected snapshot ingestion, supports gzip request body.
- `POST /api/ingest/metrics`: agent-token protected metrics ingestion for usage, object-state, requests/limits, and sampled node/pod telemetry.
