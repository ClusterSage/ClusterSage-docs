# Architecture

KubeSage uses the customer-installed connector model. The SaaS does not connect to customer Azure subscriptions, does not require Azure Lighthouse, and works with private AKS API servers because the collector runs inside the cluster and pushes outbound HTTPS traffic.

## Components

- Frontend: Next.js dashboard for auth, cluster inventory, Kubernetes resource inventory, selected resource details, pod logs, incident placeholders, AI suggestion placeholders, install guide, and settings.
- Backend: FastAPI API for users, JWT auth, agent keys, agent registration, ingestion, issue detection, audit logs, and storage writes.
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
7. The email worker consumes cluster connection events and sends Azure Communication Services Email without blocking registration.

## Tenancy

Every user, cluster, log batch, snapshot, issue, AI recommendation, and audit record is scoped by `organization_id`. Blob paths include `orgId=<org_id>` and `clusterId=<cluster_id>` prefixes. The app uses one private Blob container rather than container-per-user sprawl.
