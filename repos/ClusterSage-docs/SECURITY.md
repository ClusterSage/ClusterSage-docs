# Security

## Required Rules

- Use HTTPS in production for frontend, backend, and agent ingestion.
- Never expose Azure Storage connection strings to the customer-installed agent.
- Never expose PostgreSQL credentials to the agent.
- Store only hashed agent keys. Show raw keys once.
- Support key revocation and cluster deactivation.
- Do not collect Kubernetes Secret values.
- Do not grant cluster-admin to the agent.
- Use read-only Kubernetes RBAC.
- Validate ingestion payloads and enforce request body size limits.
- Keep audit logs for registration, login, key creation/revocation, agent registration, heartbeat, and cluster deactivation.
- Do not send secrets to future AI features.

## Agent RBAC

The Helm chart grants `get`, `list`, and `watch` only for pods, nodes, deployments, daemonsets, statefulsets, replicasets, services, ingresses, PVCs, namespaces, and events. Secrets are intentionally absent.

## Secret Handling

Backend secrets should be stored in Kubernetes Secrets, VM `.env` files with restricted permissions, or Azure Key Vault. Customer Helm values contain only the agent access key; that key can register only with the SaaS ingestion API and cannot access Blob Storage or PostgreSQL.
