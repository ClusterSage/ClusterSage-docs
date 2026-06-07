# KubeSage

KubeSage is a multi-tenant Kubernetes/AKS observability SaaS platform using **Model C: customer-installed agent/connector**. The SaaS never scans customer Azure subscriptions and never needs Azure Lighthouse. Customers install a read-only Helm agent inside their Kubernetes cluster; the agent pushes logs, events, snapshots, and health data outward to the backend over HTTPS.

The repository still contains historical technical names such as `clusterwatch-*` in chart names, namespaces, image examples, database names, and storage paths. Treat those as internal deployment identifiers unless a migration explicitly changes them.

## Architecture

```text
Customer AKS/private Kubernetes
  Fluent Bit DaemonSet -> Collector Deployment -> HTTPS ingestion API
                                                 |
ClusterWatch SaaS frontend -> FastAPI backend -> PostgreSQL metadata
                                                 -> Azure Blob Storage raw data
```

## Features

- Next.js dashboard with register, login, protected routes, cluster resource inventory, resource details, pod logs, issue placeholders, AI suggestion placeholders, settings, and agent-key management.
- FastAPI backend with JWT auth, hashed agent keys, agent registration, heartbeat, ingestion, audit logs, and OpenAPI docs.
- PostgreSQL metadata tables for users, orgs, keys, clusters, log indexes, snapshots, issues, AI recommendation metadata, and audits.
- Private Azure Blob container `clusterwatch-data` for compressed raw logs, events, snapshots, and future AI context files.
- Python in-cluster collector with Kubernetes snapshot/event collection, local Fluent Bit HTTP receiver, gzip sends, retries, and clear errors.
- Helm chart for the customer agent and separate Helm chart for the SaaS platform.

## Repository Structure

- `apps/backend` - FastAPI app, SQLAlchemy models, Alembic migration, storage writer, issue detection.
- `apps/frontend` - Next.js TypeScript dashboard and install guide.
- `agent/collector` - Python collector that runs in customer clusters.
- `agent/helm/clusterwatch-agent` - customer-installed Helm chart.
- `deploy/helm/clusterwatch-platform` - SaaS platform Helm chart for AKS.
- `terraform` - Azure infrastructure modules for Front Door, WAF, AKS, Service Bus, Key Vault, PostgreSQL, and monitoring.

## Setup Guides

- [Application setup](docs/APPLICATION_SETUP.md)
- [Azure infrastructure setup](docs/AZURE_INFRASTRUCTURE_SETUP.md)
- [Future AI design](docs/AI_FUTURE_DESIGN.md)
- `deploy/k8s`, `deploy/vm`, `deploy/vmss`, `deploy/nginx` - deployment manifests and scripts.
- `docs` - local, VM, VMSS, AKS, Helm, security, API, smoke test, and storage docs.
- `.codex` - context files for future AI coding sessions.

## Storage Design

PostgreSQL stores metadata only. Azure Blob Storage stores raw compressed JSON using one private container, not one container per customer:

```text
logs/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/batch_<uuid>.json.gz
events/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/events_<uuid>.json.gz
snapshots/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/snapshot_<uuid>.json.gz
```

## Security Design

- Agent receives only `CLUSTERWATCH_BACKEND_URL`, user email, one-time access key, cluster name, provider, and intervals.
- Agent never receives PostgreSQL credentials or Azure Storage credentials and never writes directly to storage.
- Agent keys are generated as `cw_live_<secure_random_string>`, shown once, and stored hashed with bcrypt.
- Agent RBAC is read-only and excludes Kubernetes Secrets.
- Production must use HTTPS, strong JWT secrets, private Blob container, and least-privilege Azure access.

## Local Development Quickstart

```bash
docker compose up -d
docker compose logs -f backend
docker compose exec backend alembic upgrade head
curl http://localhost:8000/health
```

Open the frontend at `http://localhost:3000`, register a user, generate an agent key, and open `/dashboard/install-agent` for dynamic Helm values.

## Agent Quickstart

```bash
helm upgrade --install clusterwatch-agent ./agent/helm/clusterwatch-agent \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
kubectl get pods -n clusterwatch-agent
kubectl logs deploy/clusterwatch-collector -n clusterwatch-agent
```

## Azure Deployment Order

1. Create resource group, ACR, PostgreSQL Flexible Server, database, firewall rules, Storage Account, and private container.
2. Build and push `clusterwatch-backend`, `clusterwatch-frontend`, and `clusterwatch-agent` images to ACR.
3. Run database migrations.
4. Deploy either VM/VMSS Docker Compose or AKS Helm chart.
5. Configure DNS and HTTPS.
6. Smoke test `/health`, register/login, create agent key, register agent, send heartbeat/logs/snapshots.

## Detailed Docs

- Local: `docs/DEPLOY_LOCAL.md`
- VM: `docs/DEPLOY_VM.md`
- VMSS: `docs/DEPLOY_VMSS.md`
- AKS: `docs/DEPLOY_AKS.md`
- Helm: `docs/DEPLOY_WITH_HELM.md`
- Agent install: `docs/AGENT_INSTALL_GUIDE.md`
- Smoke tests: `docs/SMOKE_TESTS.md`
- Troubleshooting: `docs/TROUBLESHOOTING.md`

## Cleanup

```bash
docker compose down
helm uninstall clusterwatch-agent -n clusterwatch-agent || true
kubectl delete namespace clusterwatch-agent || true
```

For Azure cleanup, delete the resource group only after confirming it contains no unrelated resources:

```bash
az group delete --name rg-clusterwatch-prod --yes --no-wait
```
