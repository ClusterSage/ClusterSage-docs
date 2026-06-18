# Cluster Dashboard

## Current State

Implemented in Phase 2 of the frontend monitoring split.

The cluster dashboard lives under:

- `/dashboard/clusters/{clusterId}/dashboard`

It is part of the cluster-specific shell and is intentionally built only from telemetry that already exists in ClusterSage today.

## Real Data Sources Used

The dashboard currently uses:

- `GET /api/clusters/{clusterId}`
- `GET /api/clusters/{clusterId}/resources`
- `GET /api/clusters/{clusterId}/incidents`

These provide:

- cluster connection status
- agent version
- last seen timestamp
- resource inventory
- pod status snapshot data
- restart counts from pod snapshot data
- incident counts and severities
- namespace-level incident grouping

## Panels Implemented

- Last seen
- Agent version
- Pods discovered
- Deployments discovered
- Resources needing attention
- Pods with restarts
- Open incidents
- Pods by status
- Incidents by severity
- Top restarted pods
- Top affected namespaces
- Resources by kind
- Recent incident activity

## Metrics Not Supported Yet

The dashboard does **not** currently have:

- CPU usage metrics
- memory usage metrics
- Metrics Server-backed usage data
- Prometheus time-series data
- backend-stored resource usage history

Because those metrics do not exist in the current agent/backend pipeline, the dashboard shows explicit unavailable states instead of fake charts.

## Limits Integration

Dashboard panels that represent alertable signals now expose `Set limit` buttons which route into:

- `/dashboard/clusters/{clusterId}/limits?metric=...`

The Limits page is now implemented. When a supported signal is chosen from the dashboard, the Limits screen opens a prefilled create flow for that metric.

Important exception:

- `Pods by status` no longer exposes `Set limit`

That panel is still valid as an inventory/status view, but `pod_status` is not a supported backend alert metric and would have created a broken handoff.

## Design Notes

- No charting library was added in this phase.
- Visual summaries use native layout and CSS bars so the dashboard stays dependency-light.
- The dashboard is monitoring-focused but does not invent data or claim unsupported telemetry.

## Future Work

- Alert limit CRUD and persistence
- backend limit evaluation
- email notifications
- optional CPU/memory telemetry, only after agent/backend support is intentionally added
