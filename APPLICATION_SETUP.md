# ClusterSage Application Setup

ClusterSage is a multi-tenant Kubernetes observability SaaS. Customers install a read-only agent in their cluster; the agent pushes logs, events, and snapshots to the FastAPI backend over HTTPS. The Next.js frontend lets authenticated users inspect clusters, resources, pod logs, incidents, and future AI suggestions.

## Architecture

- Frontend: `repos/ClusterSage-frontend`, Next.js dashboard and auth UI.
- Backend/API: `repos/ClusterSage-services/services/platform-api`, FastAPI, JWT auth, tenant-scoped cluster/resource/log APIs.
- Agent: `repos/ClusterSage-services/services/collector-agent`, Python in-cluster collector plus Fluent Bit.
- Worker: `repos/ClusterSage-services/services/email-worker`, standalone service that consumes Service Bus messages and sends Azure Communication Services Email.
- Storage: PostgreSQL metadata plus private Azure Blob Storage for raw compressed logs, events, and snapshots.

## Local Development

1. Copy `.env.example` to `.env` and adjust values.
2. Start dependencies and services:

```bash
docker compose up --build
```

3. Open the frontend at `http://localhost:3000` and the API at `http://localhost:8000`.
4. Run migrations when needed:

```bash
docker compose exec backend alembic upgrade head
```

## Container Images

- Frontend, platform API, email worker, and collector agent images are built from multi-stage Dockerfiles.
- All runtime stages run as non-root users.
- The frontend runtime uses Next.js standalone output, while the Python services copy a prebuilt virtual environment from the builder stage into a slim runtime stage.

## Environment Variables

Important backend variables:

- `DATABASE_URL`
- `JWT_SECRET`
- `AGENT_TOKEN_SECRET`
- `AZURE_STORAGE_CONNECTION_STRING`
- `AZURE_STORAGE_CONTAINER`
- `AZURE_SERVICEBUS_CONNECTION_STRING` or `AZURE_SERVICEBUS_FULLY_QUALIFIED_NAMESPACE`
- `CLUSTER_CONNECTED_QUEUE_NAME`
- `AZURE_COMMUNICATION_EMAIL_CONNECTION_STRING` or `AZURE_COMMUNICATION_EMAIL_ENDPOINT`
- `EMAIL_SENDER_ADDRESS`
- `CORS_ALLOWED_ORIGINS`

## Production Secret Delivery

Prod should not carry backend secrets in Git-tracked Helm values. The active prod target is Azure Key Vault plus AKS Workload Identity plus the Secrets Store CSI driver:

- Key Vault stores runtime secrets such as `DATABASE_URL`, `JWT_SECRET`, `AGENT_TOKEN_SECRET`, and `AZURE_STORAGE_CONNECTION_STRING`.
- The `clustersage-workloads` service account is annotated with the user-assigned managed identity client ID.
- The platform chart mounts Key Vault secrets through a `SecretProviderClass`.
- Backend, email worker, and migration pods export mounted secret files into environment variables at container start so the application code keeps the same config contract.

Important frontend variables:

- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_APP_NAME=ClusterSage`

## Authentication

Users register or log in through `/api/auth/register` and `/api/auth/login`. The backend returns a JWT that includes the user ID, organization ID, role, expiry, and user token type. Protected APIs resolve the token and enforce organization ownership before returning clusters, resources, issues, logs, or audit data.

## Cluster Connection

Users create an agent key and install the Helm agent with their email, access key, backend URL, cluster name, and provider. The agent registers through `/api/agent/register`, receives an agent token, and then sends heartbeats, logs, events, and snapshots.

## Resource Listing

The backend exposes `GET /api/clusters/{clusterId}/resources`. It reads the latest stored snapshot for the tenant-owned cluster and returns resource summaries for pods, deployments, services, ReplicaSets, StatefulSets, DaemonSets, Jobs, CronJobs, and namespaces when present.

## Log Viewing

The frontend opens logs from a selected resource detail page. Pod logs come from `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}/logs`, which validates the resource, reads recent log batches, filters by pod and namespace, and returns up to 1,000 log lines.

The frontend has a refresh cooldown. The backend also enforces endpoint-aware rate limiting.

## Email Notifications

When an agent successfully connects a cluster, the API publishes a `cluster.connected` message to Azure Service Bus. The email worker consumes the message and sends a confirmation email through Azure Communication Services Email. Failures are logged and audited without breaking cluster registration.

When alert evaluation is enabled, the platform API also evaluates stored alert-limit definitions on a background interval. Matching breaches create `alert_events` rows and queue `alert.limit_triggered` notification messages through the same Service Bus/email-worker path.

Run the worker locally when Service Bus and email are configured:

```bash
cd repos/ClusterSage-services/services/email-worker
python -m app.main
```

## Tests And Validation

```bash
cd repos/ClusterSage-frontend
npm run build

cd ../ClusterSage-services/services/platform-api
python -m compileall app

cd ../email-worker
python -m compileall app
```

## Troubleshooting

- Empty resources usually mean no snapshot has arrived yet or Blob Storage is not configured.
- Empty pod logs usually mean no Fluent Bit log batches have arrived for that pod yet.
- Email messages require Service Bus and Azure Communication Services Email configuration.
- Authentication errors usually mean a missing/expired JWT or an organization mismatch.
