# Architecture

ClusterSage uses the customer-installed connector model. The SaaS does not connect to customer Azure subscriptions, does not require Azure Lighthouse, and works with private AKS API servers because the collector runs inside the cluster and pushes outbound HTTPS traffic.

## Components

- Frontend: Next.js dashboard with two authenticated shells:
  - Onboarding shell for overview, cluster inventory, install guide, agent keys, and settings
  - Cluster shell for cluster dashboard, incidents, resources, ClusterSage AI, and selected resource drill-in pages
- Backend: FastAPI API for users, JWT auth, agent keys, agent registration, ingestion, issue detection, AI incident storage, cluster AI query history, remediation approvals/actions, audit logs, and storage writes.
- Database: PostgreSQL Flexible Server for metadata and indexes.
- Blob Storage: one private container named `clusterwatch-data` for raw compressed logs, events, snapshots, and future AI context.
- Agent: Python collector Deployment plus Fluent Bit DaemonSet installed by Helm in the customer cluster.

## Data Flow

1. User registers; backend creates an organization and owner user.
2. User creates an agent key; raw key is displayed once and hashed in PostgreSQL.
3. User installs the Helm chart with `backend.url`, `auth.email`, `auth.accessKey`, `cluster.name`, and collector image.
4. Agent registers with `/api/agent/register` and receives `cluster_id` plus signed `agent_token`.
5. Agent sends `/api/agent/heartbeat`, `/api/ingest/logs`, `/api/ingest/events`, and `/api/ingest/snapshot`.
6. Backend validates the agent token, writes raw payloads to Blob Storage, writes indexes to PostgreSQL, detects basic issues, and publishes a Service Bus notification when a cluster connects.
7. Users can review cluster-wide incidents from `/api/clusters/{clusterId}/incidents`, continue legacy safe queries through `/api/clusters/{clusterId}/ai/query`, and use the newer conversation-based investigation assistant through:
   - `POST /api/clusters/{clusterId}/ai/chat`
   - `GET /api/clusters/{clusterId}/ai/conversations`
   - `GET /api/clusters/{clusterId}/ai/conversations/{conversationId}`
8. The conversation-based assistant uses a read-only tool-calling loop with server-executed tools for incidents, issues, snapshots, deployments, logs, approved documents, and a small curated ClusterSage knowledge base. It does not execute raw SQL, arbitrary shell commands, `kubectl`, or Kubernetes mutations.
8. The standalone email worker consumes cluster connection events and sends Azure Communication Services Email without blocking registration.
9. When remediation is enabled end to end, the backend can queue approved rollout-restart actions and the agent can poll `/api/agent/actions/poll`, validate the action locally, patch the target Deployment, and report status back with `/api/agent/actions/{actionId}/status`.

## Frontend Route Model

- Onboarding routes remain under `/dashboard`:
  - `/dashboard`
  - `/dashboard/clusters`
  - `/dashboard/install-agent`
  - `/dashboard/settings`
  - `/dashboard/settings/agent-keys`
- Cluster operations routes live under `/dashboard/clusters/{clusterId}`:
  - `/dashboard/clusters/{clusterId}/dashboard`
  - `/dashboard/clusters/{clusterId}/limits`
  - `/dashboard/clusters/{clusterId}/incidents`
  - `/dashboard/clusters/{clusterId}/resources`
  - `/dashboard/clusters/{clusterId}/ai`
  - `/dashboard/clusters/{clusterId}/resources/{kind}/{namespace}/{name}`
- Legacy cluster entry routes redirect to the new cluster shell so existing deep links are less likely to break during the transition.

## Cluster Incidents UX

- The cluster incidents screen stays at `/dashboard/clusters/{clusterId}/incidents`.
- It still reads from the same cluster incident API and preserves the existing filter model.
- Incident selection now opens a right-side detail drawer for investigation instead of keeping a permanently expanded detail panel inline with the list.
- The drawer can link the user directly into the related resource detail page when the incident is tied to a concrete resource.

## Resource And AI Integration

- The resource detail route remains `/dashboard/clusters/{clusterId}/resources/{kind}/{namespace}/{name}`.
- That page still provides `Details`, `Logs`, `Incidents`, and `AI Suggestions` without changing the backend contracts.
- The resource detail screen now visually aligns with the dark cluster-shell operations workspace and includes direct links back to cluster resources, cluster incidents, and ClusterSage AI.
- The cluster-level ClusterSage AI screen remains `/dashboard/clusters/{clusterId}/ai`.
- It now presents a conversation-based investigation workspace with history, evidence chips, confidence/freshness indicators, retry handling, and a new-conversation action.
- The older fixed-question flow is no longer the primary frontend experience, but the legacy backend query endpoint still remains available for backward compatibility.

## Cluster Investigation Agent

- Backend agent architecture now separates:
  - orchestration under `app/ai/agent`
  - tool definitions and execution under `app/ai/tools`
  - curated static knowledge under `app/ai/knowledge_base`
- Conversation persistence now uses:
  - `ai_conversations`
  - `ai_messages`
- Tool execution is server-scoped by organization, user, cluster, and conversation context.
- Conversation context is bounded to recent messages only; it does not resend full prior tool payloads or persist hidden reasoning.
- Retrieved logs, documents, and knowledge-base excerpts are treated as untrusted evidence and redacted before being sent back into the model loop.

## Tenancy

Every user, cluster, log batch, snapshot, issue, AI recommendation, and audit record is scoped by `organization_id`. Blob paths include `orgId=<org_id>` and `clusterId=<cluster_id>` prefixes. The app uses one private Blob container rather than container-per-user sprawl.
