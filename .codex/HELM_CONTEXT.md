# Helm Context

Customer chart: `agent/helm/clusterwatch-agent`. It installs read-only RBAC, collector Deployment/Service, Fluent Bit ConfigMap/DaemonSet, and Secret for email/access key.

Platform chart: `deploy/helm/clusterwatch-platform`. It installs frontend/backend Deployments, Services, Ingress, ConfigMap, Secret, and optional Alembic migration Job.
