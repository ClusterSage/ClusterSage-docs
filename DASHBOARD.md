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

## Dashboard Foundation Refresh

Phase 1 of the current focused visual refactor updated the shared dashboard presentation layer without changing dashboard data sources or backend behavior.

Files involved:

- `repos/ClusterSage-frontend/src/components/ClusterShell.tsx`
- `repos/ClusterSage-frontend/src/components/clusters/dashboard/DashboardMetricCard.tsx`
- `repos/ClusterSage-frontend/src/components/clusters/dashboard/DashboardPanel.tsx`
- `repos/ClusterSage-frontend/src/components/clusters/dashboard/DashboardUnavailableState.tsx`
- `repos/ClusterSage-frontend/src/app/globals.css`

Implemented in this phase:

- tighter light/dark dashboard surface tokens
- calmer cluster shell chrome
- icon-led cluster sidebar navigation
- shared metric-card trend framing
- explicit unavailable trend placeholder when no historical sparkline data exists
- reusable unavailable state primitive for later dashboard panels

Not changed in this phase:

- route structure
- API contracts
- query keys
- organization or cluster scoping
- alert-limit backend behavior
- metrics aggregation logic
- incident or AI insight logic

Validation completed:

- `npm run lint`
- `npm run build`

## Phase 2 Top-Surface Refresh

The current dashboard header and summary strip were tightened to better match the intended premium operations-console feel without changing backend behavior.

Files involved:

- `repos/ClusterSage-frontend/src/components/clusters/ClusterDashboardView.tsx`

Implemented in this phase:

- denser overview header with:
  - cluster connection-state pill
  - snapshot/telemetry status pill
  - existing time-range selector
  - existing refresh control
- five-card summary row now aligned to:
  - `Cluster status`
  - `Nodes`
  - `Workloads`
  - `Incidents`
  - `Alerts`
- the `Alerts` card now uses the real backend alert-event feed:
  - `GET /api/clusters/{clusterId}/alert-events`
- alert sparkline activity is derived only from real `triggered_at` values inside the selected time window
- incident sparkline activity still derives from real incident timestamps
- cluster and workload cards stay honest snapshot summaries and do not fake historical trend lines when the backend does not expose them

Not changed in this phase:

- backend alert evaluation behavior
- metrics ingestion behavior
- limits CRUD behavior
- cluster-shell routing
- lower technical panels

Validation completed:

- `npm run lint`
- `npm run build`

## Phase 3 Middle-Row Refresh

The dashboard middle row was reworked to read more like a real observability surface while still staying fully tied to existing data.

Files involved:

- `repos/ClusterSage-frontend/src/components/clusters/ClusterDashboardView.tsx`
- `repos/ClusterSage-frontend/src/components/clusters/dashboard/DashboardUnavailableState.tsx`

Implemented in this phase:

- `Cluster health` panel now uses:
  - denser internal health rows
  - supporting stat tiles for pods, incidents, and critical incidents
  - truthful empty-state handling when no pod snapshot exists
- `Recent incidents` panel now uses:
  - summary tiles for open / critical / major counts
  - denser incident rows with severity, type, status, recency, and occurrence count
- `AI insights` panel now uses:
  - summary tiles for visible insights and severity mix
  - denser AI summary cards with severity context and insight tags
  - truthful empty-state handling when no incident rows contain `ai_summary`

Truthfulness constraints preserved:

- cluster health is still derived from real pod states plus open major/critical incidents
- recent incidents still come only from existing incident rows already fetched for the dashboard
- AI insights still render only records that already have a real `ai_summary`
- no synthetic cluster-wide AI advice was added

Not changed in this phase:

- backend APIs
- incident evaluation logic
- AI generation logic
- route structure
- lower telemetry panels

Validation completed:

- `npm run lint`
- `npm run build`

## Phase 4 Lower Technical Surface Refresh

The lower half of the dashboard was reorganized so it reads like a stacked technical workspace instead of a separate utilitarian block under a more polished top section.

Files involved:

- `repos/ClusterSage-frontend/src/components/clusters/ClusterDashboardView.tsx`

Implemented in this phase:

- `Technical telemetry` now uses:
  - a framed parent section surface
  - compact runtime summary tiles ahead of the charts
  - stronger hierarchy for:
    - CPU, memory, and network line panels
    - current runtime totals
    - request and limit breakdown panels
- `Hot spots and workload shape` now uses:
  - a framed parent section surface
  - compact snapshot/distribution summary tiles
  - stronger hierarchy for:
    - namespace status
    - workload health
    - top pod/node consumer lists
- child panels now use more consistent eyebrow labeling so the whole lower half feels like one observability system

Truthfulness constraints preserved:

- no new backend APIs were introduced
- runtime and distribution panels still render only from the existing telemetry, snapshot, and incident data already available
- absent telemetry still results in empty or unavailable states rather than fabricated values

Not changed in this phase:

- backend metrics aggregation
- route structure
- alert-limit backend behavior
- incident or AI generation logic

Validation completed:

- `npm run lint`
- `npm run build`

## Phase 5 Cross-Screen Consistency Pass

The final pass aligned the rest of the cluster-facing screens with the new dashboard surface language so the workspace feels like one product instead of a polished dashboard next to older operational pages.

Files involved:

- `repos/ClusterSage-frontend/src/components/clusters/ClusterWorkspaceView.tsx`
- `repos/ClusterSage-frontend/src/components/clusters/ClusterLimitsView.tsx`
- `repos/ClusterSage-frontend/src/app/dashboard/clusters/[clusterId]/resources/[kind]/[namespace]/[name]/page.tsx`

Implemented in this phase:

- resources view now uses the same denser metric-card and panel framing as the dashboard
- incidents view now uses tighter summary cards and shared surface treatment for filter/help rows
- ClusterSage AI view now uses the same card/panel hierarchy for supported intents and result output
- limits view now uses the shared metric-card and panel treatment for top summaries and main work areas
- resource detail now uses the same surface language for:
  - summary cards
  - metadata/runtime blocks
  - logs
  - incident detail side content
  - AI suggestion cards

Not changed in this phase:

- backend APIs
- remediation approval behavior
- alert-limit logic
- route structure
- data semantics

Validation completed:

- `npm run lint`
- `npm run build`

## Phase 6 Shared Shell Polish

The final chrome pass tightened the shared shells around the cluster workspace and onboarding workspace so the navigation and top bars no longer feel bulkier than the content surfaces.

Files involved:

- `repos/ClusterSage-frontend/src/components/ClusterShell.tsx`
- `repos/ClusterSage-frontend/src/components/DashboardShell.tsx`

Implemented in this phase:

- cluster shell:
  - shorter AI nav label
  - denser current-cluster card
  - slightly tighter sidebar width
  - smaller top bar and a more minimal back control
- onboarding shell:
  - icon-led nav treatment to better match the cluster shell
  - tighter sidebar width
  - smaller top bar heading treatment

Not changed in this phase:

- page routes
- auth behavior
- backend APIs
- dashboard data behavior

Validation completed:

- `npm run lint`
- `npm run build`
