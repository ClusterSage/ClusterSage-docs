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

## Runtime Metrics Now Shown When Available

The dashboard can now render runtime CPU and memory panels when the cluster is successfully sending Metrics API samples through the agent and backend.

Current runtime panels:

- total pod CPU usage
- total pod memory usage
- top pods by CPU
- top nodes by CPU
- top pods by memory
- top nodes by memory

These are sourced from:

- `GET /api/clusters/{clusterId}/metrics/overview`

Backend Phase 2 query surfaces now also exist for the next-generation technical dashboard:

- `GET /api/clusters/{clusterId}/metrics/catalog`
- `GET /api/clusters/{clusterId}/metrics/latest`
- `GET /api/clusters/{clusterId}/metrics/timeseries`

These are intended for:

- filter dropdown population
- filtered top-panel summaries
- historical line and bar charts
- namespace/node/workload/pod drilldowns

## Metrics Still Not Fully Supported Yet

The dashboard still does **not** currently have:

- CPU usage metrics
- memory usage metrics
- Metrics Server-backed usage data
- Prometheus time-series data
- backend-stored resource usage history

When runtime metrics are unavailable for a cluster, the dashboard shows explicit unavailable states instead of fake charts.

## Runtime Metrics Groundwork

Phase 2 backend and agent groundwork now exists for runtime metrics:

- agent-side read-only polling of the Kubernetes Metrics API
- backend ingest at `POST /api/ingest/metrics`
- backend overview read path at `GET /api/clusters/{clusterId}/metrics/overview`
- additive storage in `cluster_metric_samples`
- additive metrics query surfaces at:
  - `GET /api/clusters/{clusterId}/metrics/catalog`
  - `GET /api/clusters/{clusterId}/metrics/latest`
  - `GET /api/clusters/{clusterId}/metrics/timeseries`

The runtime panels only become active once:

- the customer cluster has Metrics Server available
- the agent is collecting metrics successfully
- the backend overview endpoint is returning real data for that cluster

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
- richer telemetry-backed technical dashboard rollout:
  - chart-managed `kube-state-metrics`
  - optional chart-managed `metrics-server`
  - collector scraping of object-state metrics, requests/limits, kubelet summary, and live usage
  - backend historical/query APIs for Grafana-style cluster views

## Advanced Technical Dashboard

The cluster dashboard is now moving toward a denser Grafana-style operations surface.

Current frontend implementation now uses:

- `GET /api/clusters/{clusterId}/metrics/catalog`
- `GET /api/clusters/{clusterId}/metrics/latest`
- `GET /api/clusters/{clusterId}/metrics/timeseries`
- existing snapshot and incident APIs

Current technical dashboard behaviors:

- node / namespace / workload / pod filter bar
- CPU, memory, and network time-series panels backed by real data only
- requests and limits breakdown panels backed by `kube-state-metrics`
- namespace status table backed by snapshot + incident data
- workload health table backed by snapshot + incident data

Important truthfulness constraints:

- workload filtering is only applied to panels whose real backend data can support it
- pod and node metrics are not falsely remapped into workload scope when that correlation is not actually stored
- no panel renders fabricated values when telemetry is absent
