# AI Future Design

ClusterSage is transitioning from AI-ready placeholders to a phased AI implementation.

Current implementation state:

- Phase 1 is implemented: additive database schema, backend config flags, and response-model groundwork for AI incidents, remediation approvals/actions, and cluster AI query history.
- Phase 2 backend ingestion-side AI groundwork is implemented:
  - log batches are still uploaded to Blob Storage first
  - backend log preprocessing redacts likely secrets before analysis
  - repeated log patterns are grouped into AI findings
  - AI incidents and remediation suggestions are upserted into PostgreSQL
  - Azure AI Foundry can be called when enabled and configured
  - deterministic fallback analysis is used when AI is disabled, unavailable, or returns invalid output
- AI analysis is intentionally non-blocking for ingestion; failures in the AI path must not prevent raw log batch ingestion.
- Phase 3 resource-scoped read experience is implemented:
  - backend serves resource incidents and AI suggestions
  - frontend resource detail tabs render incident summaries, filters, evidence previews, and AI suggestion cards
- Phase 4 approval workflow is partially implemented:
  - backend supports approval and rejection endpoints for remediation suggestions
  - backend can create `remediation_actions` in `queued` state for approved rollout restarts
  - frontend shows approval and rejection UX with explicit confirmation
- Phase 5 agent execution wiring is implemented:
  - backend exposes agent polling, capabilities, and status-reporting endpoints
  - collector agent polls for queued actions
  - collector validates action type, cluster, namespace allowlist, and deployment target
  - collector performs rollout restarts by patching Deployment pod-template annotations
  - collector reports running and terminal status back to backend
- Phase 6 chart wiring is implemented:
  - remediation values and minimal optional write RBAC now exist in the agent Helm chart
  - end-to-end rollout restarts still depend on remediation being explicitly enabled at deploy time
- Phase 7 cluster-level AI read experience is implemented:
  - backend serves `GET /api/clusters/{clusterId}/incidents`
  - backend serves `POST /api/clusters/{clusterId}/ai/query`
  - frontend cluster detail page now includes `Incidents` and `ClusterSage AI` tabs
  - cluster AI queries are parsed into a strict allowlisted DSL before any backend query logic runs

## Stored Context

Future recommendations can use:

- Raw compressed logs in Blob Storage.
- Kubernetes events in Blob Storage.
- Cluster snapshots in Blob Storage.
- Issue rows and AI recommendation metadata in PostgreSQL.
- Phase 1 additive tables for AI findings, AI incidents, remediation suggestions, remediation approvals/actions, and cluster AI query history.

## Current Backend AI Flow

1. Agent posts `/api/ingest/logs`.
2. Backend writes the raw compressed batch to Blob Storage and commits the `log_batches` record.
3. Backend then performs best-effort AI preprocessing and persistence:
   - secret redaction
   - pattern classification
   - incident grouping
   - optional Azure AI Foundry call
   - fallback summary and suggestion generation
   - `ai_log_findings`, `ai_incidents`, and `remediation_suggestions` upserts
4. If the AI path throws, the session is rolled back for AI-side writes and ingestion still returns success.

## Current User-Facing Endpoints

- `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}/incidents`
- `GET /api/clusters/{clusterId}/resources/{kind}/{namespace}/{name}/ai-suggestions`
- `GET /api/clusters/{clusterId}/incidents`
- `POST /api/clusters/{clusterId}/ai/query`
- `POST /api/remediation-suggestions/{suggestionId}/approve`
- `POST /api/remediation-suggestions/{suggestionId}/reject`
- `GET /api/remediation-actions/{actionId}`

## Current Agent-Facing Endpoints

- `POST /api/agent/actions/poll`
- `POST /api/agent/actions/{actionId}/status`
- `POST /api/agent/capabilities`

## Current Limitations

- Many rollout-restart suggestions will still appear non-executable until the backend has a safe Deployment target and remediation is enabled in both backend and agent configuration.
- Workload ownership resolution from pod to Deployment or StatefulSet is still partial and strongest for paths already represented in the latest cluster snapshot.
- Cluster-wide querying currently uses a deterministic parser and fixed supported intents; it is not yet a broad natural-language understanding layer.
- Cluster AI answers are limited to already stored cluster telemetry and should not be treated as real-time kubectl output.
- Approval UI may still show disabled states for many suggestions until a safe executable deployment target is present and environment-level agent remediation is enabled.
- Helm-managed remediation RBAC now exists, but it is disabled by default and still needs live-cluster validation before being treated as production-ready.

## Safety Rules

- Never include Kubernetes Secret values.
- Redact environment variables likely to contain credentials before AI processing.
- Keep AI prompts scoped to one organization, cluster, and selected resource whenever possible.
- Store model-derived structured output in the additive AI tables introduced by Phase 1.
- Keep raw context in Blob Storage; do not duplicate large logs in PostgreSQL.
- Keep AI suggestion execution disabled until explicit approval and workload-target validation are implemented.
