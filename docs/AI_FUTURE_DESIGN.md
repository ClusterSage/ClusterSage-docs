# AI Future Design

KubeSage is AI-ready without calling an AI provider today.

The current resource detail page includes Incidents and AI Suggestions tabs as placeholders. They must remain honest placeholders until a real AI detection/remediation pipeline exists.

## Stored Context

Future recommendations can use:

- Raw compressed logs in Blob Storage.
- Kubernetes events in Blob Storage.
- Cluster snapshots in Blob Storage.
- Issue rows and AI recommendation metadata in PostgreSQL.

## Safety Rules

- Never include Kubernetes Secret values.
- Redact environment variables likely to contain credentials before AI processing.
- Keep AI prompts scoped to one organization, cluster, and selected resource whenever possible.
- Store model output in `ai_recommendations.recommendation_json` with issue linkage when applicable.
- Keep raw context in Blob Storage; do not duplicate large logs in PostgreSQL.
