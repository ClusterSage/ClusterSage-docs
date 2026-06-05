# Agent Context

Agent path: `agent/collector`. It is a Python FastAPI process running inside Kubernetes. On startup it registers with backend using email + access key + cluster name, receives `cluster_id` and `agent_token`, sends heartbeats, collects Kubernetes snapshots/events, receives Fluent Bit logs at `/logs`, batches logs, gzip-compresses ingestion requests, and retries sends with exponential backoff.

It must never collect Kubernetes Secret values or receive cloud/database credentials.
