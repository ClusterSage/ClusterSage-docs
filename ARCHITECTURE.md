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
7. Users can review cluster-wide incidents from `/api/clusters/{clusterId}/incidents` and ask supported natural-language cluster questions through `/api/clusters/{clusterId}/ai/query`; the backend parses those requests into a strict internal DSL instead of executing raw SQL.
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
- The cluster-level ClusterSage AI screen remains `/dashboard/clusters/{clusterId}/ai` and still uses the same safe backend query flow, but now presents supported-query framing more clearly inside the cluster shell.

## Tenancy

Every user, cluster, log batch, snapshot, issue, AI recommendation, and audit record is scoped by `organization_id`. Blob paths include `orgId=<org_id>` and `clusterId=<cluster_id>` prefixes. The app uses one private Blob container rather than container-per-user sprawl.
