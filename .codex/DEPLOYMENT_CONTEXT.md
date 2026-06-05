# Deployment Context

Local deployment uses `docker-compose.yml` with frontend, backend, PostgreSQL, and Azurite. VM deployment uses `infra/docker-compose.prod.yml` with managed PostgreSQL and Blob Storage. AKS deployment can use raw manifests in `deploy/k8s` or Helm chart in `deploy/helm/clusterwatch-platform`. Azure runbooks live under `docs/DEPLOY_*.md`.
