# Security Context

Security invariants: HTTPS in production, hashed agent keys only, raw keys shown once, revocation supported, no customer storage/database secrets in the agent, no Kubernetes Secret collection, no cluster-admin, read-only RBAC, validated ingestion payloads, request size limits, audit logs, and no secrets sent to future AI features.
