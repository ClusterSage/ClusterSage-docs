# Alert Limits

## Current State

Implemented through backend/database Phase 7.

What exists now:

- alert limit database tables
- cluster-scoped authenticated CRUD APIs
- enable/disable endpoints
- alert event read API
- audit logging for alert limit changes
- cooldown and notification-target fields stored on each limit
- frontend alert management UI in the cluster shell
- dashboard-to-limits metric handoff for supported signals
- backend alert evaluation service
- feature-flagged background evaluation loop in the platform API
- Service Bus notification publishing for alert-threshold emails
- email worker handling for alert-threshold messages

What still remains limited:

- CPU and memory thresholding still do not exist
- snapshot-based metrics are evaluated from the latest known snapshot, not from a full metrics timeseries backend
- `notification_sent` on `alert_events` reflects successful notification queue dispatch, not downstream Azure Communication Services delivery confirmation

## Supported Metric Types

The backend currently accepts only metric types that align with real telemetry already present in ClusterSage:

- `resource_health`
- `pod_restarts`
- `open_incidents`
- `critical_incidents`
- `major_incidents`
- `minor_incidents`
- `warning_events`

CPU and memory metrics are not supported because the current agent/backend pipeline does not collect or store them.

## Evaluation Model

When `ALERT_EVALUATION_ENABLED=true`, the platform API starts a background loop that evaluates enabled limits on a fixed interval.

Current evaluation behavior:

- `resource_health`: counts unhealthy resources from the latest cluster snapshot
- `pod_restarts`: uses the highest pod restart count found in the latest matching pod snapshot
- `open_incidents`, `critical_incidents`, `major_incidents`, `minor_incidents`: count matching open AI incidents seen within the configured time window
- `warning_events`: counts matching warning-style issue rows derived from Kubernetes events within the configured time window

Cooldown behavior:

- if a limit has triggered within its `cooldown_minutes` window, it is skipped until cooldown expires
- when a breach is recorded, `last_triggered_at` is updated and an `alert_events` row is created

Notification behavior:

- if email is enabled for the limit, the backend publishes an alert message to Azure Service Bus
- the standalone email worker consumes that message and sends email through Azure Communication Services Email
- alert evaluation does not send email directly from the API request/response path
- when the backend is running on PostgreSQL, each evaluation cycle uses a Postgres advisory lock so only one API instance performs the alert pass at a time

## Scope Rules

Supported scope types:

- `cluster`
- `namespace`
- `workload`
- `resource`

Validation rules:

- `namespace` scope requires `namespace`
- `workload` scope requires `workload_name`
- `resource` scope requires `resource_id`
- cluster-wide incident and warning-event metrics currently require `cluster` scope

## API Endpoints

All endpoints require authenticated user access and verify that the cluster belongs to the user organization.

- `GET /api/clusters/{clusterId}/limits`
- `POST /api/clusters/{clusterId}/limits`
- `PATCH /api/clusters/{clusterId}/limits/{limitId}`
- `POST /api/clusters/{clusterId}/limits/{limitId}/enable`
- `POST /api/clusters/{clusterId}/limits/{limitId}/disable`
- `DELETE /api/clusters/{clusterId}/limits/{limitId}`
- `GET /api/clusters/{clusterId}/alert-events`

## Frontend UX

The cluster-shell Limits experience now lives at:

- `/dashboard/clusters/{clusterId}/limits`

What users can do there now:

- list existing limits
- create a new limit from supported telemetry signals
- edit limit fields
- enable or disable a limit
- delete a limit with confirmation
- inspect stored trigger history rows if present

The dashboard `Set limit` actions for supported signals now land on this route with a `metric` query param and open a prefilled create flow.

Signals shown in the dashboard but intentionally **not** offered as limit types include:

- pod status distribution
- CPU usage
- memory usage

Those are visible or placeholder-only, but not currently backed by supported alert evaluation telemetry.

## Database Tables

### `alert_limits`

Stores the configured alert threshold and notification settings.

### `alert_events`

Stores historical trigger rows for evaluated breaches.

Current meaning of fields:

- `metric_value`: observed value at evaluation time
- `threshold_value`: configured threshold
- `notification_sent`: notification event was successfully queued for email delivery
- `notification_error`: queueing failed or notifications were not configured

## Security Notes

- limits are organization-scoped through the cluster relationship
- endpoints validate supported metric types
- no frontend-only alerting logic is relied on
- no email is sent from the browser
- cooldown is enforced in the backend to reduce repeated alert spam
- alert emails currently share the existing notification worker and Service Bus queue used for other operational emails
