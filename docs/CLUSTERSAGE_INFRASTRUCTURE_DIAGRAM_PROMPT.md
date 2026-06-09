# ClusterSage draw.io Architecture Diagram Refinement Prompt

You are a senior Azure cloud architect, DevOps engineer, SRE, platform engineer, Kubernetes architect, security architect, and technical diagram designer.

I have an existing `diagram.drawio` file for the ClusterSage Azure architecture. The current architecture is mostly correct, but the diagram is too wide, visually confusing, and difficult to read in draw.io.

Your task is to refine the draw.io architecture diagram without changing the core architecture meaning. Make it cleaner, more readable, more realistic, and better structured for a technical Azure project review and implementation planning.

Do not create an overly wide canvas. Redesign the layout so it works well in draw.io using multiple pages or stacked sections.

## Application Context

Application name:

```text
ClusterSage
```

One-line description:

```text
ClusterSage is a multi-tenant Kubernetes observability SaaS that uses a read-only in-cluster agent to stream resource health, events, logs, and snapshots into a centralized dashboard.
```

ClusterSage is a multi-tenant Kubernetes/AKS observability SaaS platform.

Customers install a read-only ClusterSage agent inside their Kubernetes or AKS clusters. The agent sends heartbeats, logs, Kubernetes events, resource metadata, and snapshots outbound to the ClusterSage SaaS platform over HTTPS.

The current production architecture uses:

- Azure Front Door Premium
- Azure Front Door WAF
- AKS
- kgateway / Kubernetes Gateway API
- Next.js frontend
- FastAPI backend API and ingestion API
- Separate email worker deployment
- Azure PostgreSQL Flexible Server
- Azure Blob Storage
- Azure Service Bus
- Azure Communication Services Email
- Azure Key Vault
- Azure Container Registry
- Azure Monitor
- Log Analytics
- Application Insights
- User-assigned Managed Identity
- AKS Workload Identity
- Terraform
- Helm

Future/planned AI capability:

- Azure AI Foundry or an equivalent Azure AI service may be added later for incident detection, error analysis, root cause explanation, and remediation suggestions.
- If shown, AI must be clearly labeled as future/planned or optional.
- Do not show AI as part of the current production critical path.
- Do not show Azure AI directly connecting to customer clusters.

## Required Subscription Model

The diagram must follow the agreed 2-subscription model.

### 1. Non-Prod Subscription

```text
clustersage-nonprod
```

Contains:

- Dev environment
- Staging environment

### 2. Prod Subscription

```text
clustersage-prod
```

Contains:

- Production only

Production runtime, production data, production secrets, and production observability must be isolated from non-prod.

Shared resources are allowed only for safe build-plane/platform purposes, such as CI/CD templates, Terraform/Helm code, and optionally shared or replicated container registry patterns.

## Main Diagram Objective

Refine the architecture diagram so it clearly shows:

1. How users access ClusterSage.
2. How app-native login and JWT authentication work.
3. How customer cluster agents send heartbeats, logs, events, metadata, and snapshots.
4. How traffic flows through DNS, Azure Front Door, WAF, kgateway, Gateway API, and AKS services.
5. How the backend stores metadata and raw observability payloads.
6. How async email notifications work using Service Bus and Azure Communication Services Email.
7. How Managed Identity and AKS Workload Identity are used for Azure resource access.
8. How CI/CD builds, promotes, and deploys the platform across dev, staging, and prod.
9. How dev, staging, and prod are separated.
10. How observability, security, governance, and production hardening are represented.
11. Where future AI incident detection and suggestions may be added without implying that it is active today.

The refined architecture should be clear enough for a technical presentation and accurate enough for implementation planning.

## Branding And Naming Cleanup

Use the product name ClusterSage consistently in user-facing labels.

Prefer clean diagram labels:

```text
clustersage-frontend
clustersage-backend
clustersage-agent
clustersage-email-worker
clustersage-ai-worker (future/planned)
clustersage-migrations
namespace: clustersage
namespace: clustersage-agent
rg-clustersage-prod
aks-clustersage-prod
kv-clustersage-prod
sb-clustersage-prod
acr-clustersage-prod
```

The actual deployed system still contains some legacy internal names. If these names must appear for accuracy, place them in a small note, not as the main visual labels:

```text
Note: Some deployed internal resources still use legacy names such as clusterwatch-* or clustersage-* during migration.
```

Current production naming context to include in a small "current deployment" note or callout:

```text
Resource group: rg-clustersage-prod
AKS: aks-clustersage-prod
ACR: acrclustersageprod
Front Door profile: afd-clustersage-prod
Front Door endpoint: fde-clustersage-prod-dghqfrezc4asbqek.z03.azurefd.net
kgateway public Gateway: clustersage-public
kgateway LoadBalancer IP: 20.120.27.146
Front Door origin host: clustersage-prod-origin.eastus.cloudapp.azure.com
Service Bus namespace: sb-clustersage-prod
Service Bus queue: cluster-connected
Communication Service: acs-clustersage-prod
Email Communication Service: email-clustersage-prod
Key Vault: kvclustersageprod
Storage account: stclustersageprod
Blob container: clusterwatch-data
PostgreSQL server: pg-clustersage-prod-ci.postgres.database.azure.com
Canonical domain: www.nexaflow.site
Root domain: nexaflow.site redirects to www.nexaflow.site unless Azure DNS apex alias is added later
```

Do not let the diagram visually confuse ClusterSage with ClusterSage, clustersage, ClusterWatch, or clusterwatch. Use ClusterSage labels as the main labels.

## Required Diagram Structure

The current diagram is too wide. Redesign it into a cleaner, page-based structure.

Preferred draw.io structure:

1. Page 1: High-Level Production Runtime Architecture
2. Page 2: CI/CD And Environment Promotion
3. Page 3: Customer Agent And Ingestion Flow
4. Page 4: Identity, Data, Notifications, And Future AI Flow

If multiple pages are not possible, create one page with four stacked horizontal bands instead of one wide row.

Use clear grouping boxes and swimlanes:

- External actors
- DNS and edge
- AKS runtime
- Data and messaging services
- Identity and security
- Observability and governance
- Future/planned AI capability
- Non-prod and prod environment boundaries

Use a layout close to 16:9 or A3 landscape per page.

Avoid:

- Extremely wide horizontal chains
- Tiny unreadable text
- Overlapping connectors
- Repeating every detail in dev, staging, and prod
- Mixing CI/CD, runtime, customer agent flow, AI flow, and legend into one crowded canvas

## Page 1: High-Level Production Runtime Architecture

Show the main production runtime.

Use this traffic flow:

```text
Users / Customer Agents
-> GoDaddy DNS
-> Azure Front Door Premium
-> Front Door WAF + Bot Protection + Rate Limiting
-> Front Door origin: kgateway external LoadBalancer
-> AKS cluster
-> Gateway API HTTPRoutes
-> Frontend / Backend / Workers
-> Azure Data, Messaging, Email, Monitoring, and Security Services
```

Production browser flow:

```text
Browser
-> https://www.nexaflow.site
-> Azure Front Door Premium
-> WAF Policy / Bot Protection / Rate Limiting
-> Front Door origin: kgateway external LoadBalancer
-> AKS cluster
-> Gateway API HTTPRoutes
-> clustersage-frontend
-> clustersage-backend APIs
```

Root domain behavior:

```text
nexaflow.site -> redirects to https://www.nexaflow.site
```

Show GoDaddy DNS as the external DNS provider.

Show manual DNS items:

- CNAME for `www`
- TXT validation record for Azure Front Door custom domain
- root redirect from `nexaflow.site` to `www.nexaflow.site`, or future Azure DNS apex alias

Use clear grouped sections:

1. External actors
2. DNS and edge
3. AKS runtime
4. Data and messaging services
5. Identity and security
6. Observability and governance
7. Future/planned AI capability

Do not stretch everything into one long row. Keep this page readable.

## Page 2: CI/CD And Environment Promotion

Move build/platform details to a separate page.

Show this flow:

```text
Developer
-> GitHub repository
-> GitHub Actions or Azure DevOps
-> Entra ID OIDC federation
-> Build frontend image
-> Build backend image
-> Build agent image
-> Push images to Azure Container Registry
-> Terraform plan/apply
-> Helm upgrade/install
-> Deploy to dev
-> Promote to staging
-> Manual approval
-> Deploy to production
```

Show that:

- CI/CD is shared platform automation.
- CI/CD uses Entra ID OIDC/federated identity, not static Azure credentials.
- Container images are pushed to Azure Container Registry.
- Terraform provisions Azure infrastructure.
- Helm deploys the platform chart to AKS.
- Dev and staging are deployed before production.
- Production deployment requires manual approval.
- Production secrets, runtime, data, and observability are not shared with non-prod.

Show image examples:

```text
clustersage-frontend
clustersage-backend
clustersage-agent
clustersage-email-worker uses backend image today
clustersage-ai-worker future/planned
```

Also show current internal image names in a small note if needed:

```text
Current images may still use clusterwatch-frontend, clusterwatch-backend, and clusterwatch-agent.
```

Do not show manual image copying between environments. Use promotion flow.

## Page 3: Customer Agent And Ingestion Flow

Create a focused customer-agent ingestion page.

Show customer clusters as external to the ClusterSage Azure subscription.

Customer cluster structure:

```text
Customer Kubernetes / AKS Cluster
  namespace: clustersage-agent
    clustersage-collector Deployment
    clustersage-fluent-bit DaemonSet
    ServiceAccount
    read-only ClusterRole
    ClusterRoleBinding
    bootstrap Secret / agent token
```

Agent permissions:

```text
pods
nodes
services
PVCs
namespaces
events
deployments
daemonsets
statefulsets
replicasets
jobs
cronjobs
ingresses
```

Security notes:

```text
No Kubernetes Secret access
No inbound access into customer clusters
Outbound HTTPS only
No Azure Lighthouse required
No direct customer subscription scanning
```

Agent registration flow:

```text
Customer Cluster Agent
-> outbound HTTPS
-> https://www.nexaflow.site/api/agent/register
-> Azure Front Door/WAF
-> kgateway
-> backend agent registration API
-> PostgreSQL cluster record
-> signed agent token returned
```

Agent runtime flow:

```text
Customer Cluster Agent
-> /api/agent/heartbeat
-> /api/ingest/logs
-> /api/ingest/events
-> /api/ingest/snapshot
-> Azure Front Door/WAF
-> kgateway
-> backend ingest API
-> PostgreSQL metadata + Blob Storage raw payloads
```

Show:

- Fluent Bit forwards container logs to collector service inside the customer cluster.
- Collector compresses payloads with gzip.
- Data is scoped by `organization_id` and `cluster_id`.
- AI never connects directly to customer clusters; AI only analyzes already-ingested data.

## Page 4: Identity, Data, Notifications, And Future AI Flow

Create a focused page for internal service dependencies.

### End-User Authentication Flow

Clearly show that Microsoft Entra ID is not used for end-user SaaS login.

End-user login uses:

```text
User
-> ClusterSage frontend
-> Backend /api/auth/*
-> Email/password validation
-> Password hash in PostgreSQL
-> JWT token issued
-> JWT used in Authorization header for API calls
```

Add this note:

```text
End-user SaaS login = app-native email/password + JWT.
Microsoft Entra ID = Azure workload identity, infrastructure identity, and CI/CD identity only.
```

Application-level tenant isolation:

```text
organization_id
user_id
cluster_id
resource_id
```

Backend must enforce organization-based access control.

### Azure Resource Identity Flow

Clearly separate Azure resource identity from end-user authentication.

Show:

```text
Microsoft Entra ID
-> User-assigned Managed Identity
-> AKS Workload Identity federation
-> Kubernetes ServiceAccount: clusterwatch-workloads / clustersage-workloads
-> Azure resources
```

Workload Identity is currently used for:

```text
backend -> Service Bus sender
email worker -> Service Bus receiver
email worker -> Azure Communication Services Email sender
AKS kubelet identity -> ACR image pull
```

Recommended next secretless paths:

```text
backend -> Blob Storage using Managed Identity
backend -> Key Vault using Managed Identity
migrations -> Key Vault / database migration secrets
future AI worker -> Azure AI service using Managed Identity, if supported
```

Use Managed Identity wherever possible. Use Key Vault only for secrets that cannot be handled through identity-based access.

### Data Plane

Show backend connections to:

```text
PostgreSQL Flexible Server
Blob Storage
Key Vault
Service Bus Queue
Application Insights
Log Analytics
```

PostgreSQL stores structured application data:

```text
organizations
users
agent_keys
clusters
log_batches
cluster_snapshots
issues
ai_recommendations metadata
audit_logs
```

Blob Storage stores large observability payloads:

```text
logs/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/*.json.gz
events/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/*.json.gz
snapshots/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/*.json.gz
```

Key Vault stores sensitive values such as:

```text
JWT secret
agent token secret
database credentials if needed
storage credentials until Blob Managed Identity is implemented
future AI provider keys if needed
email provider secrets only if identity-based email access is unavailable
```

Prefer Managed Identity and Workload Identity instead of connection strings wherever possible.

### Email Notification Flow

Show this async email flow:

```text
User connects cluster
-> Backend validates key and stores/updates cluster connection
-> Backend publishes cluster.connected event
-> Azure Service Bus queue: cluster-connected
-> clustersage-email-worker consumes event
-> Azure Communication Services Email
-> User receives cluster connected email
```

Important note:

```text
Email failure must not block cluster registration.
```

### Future AI Incident Detection And Suggestions

Show this as future/planned, not current production-critical.

Add a dashed or differently colored section:

```text
Future AI capability
```

Future AI may analyze:

```text
Kubernetes logs
Kubernetes events
Pod failures
CrashLoopBackOff
ImagePullBackOff
Failed deployments
Node pressure
Resource limits
Configuration issues
Cluster snapshots
Historical issues/incidents
```

Future AI flow:

```text
Logs / Events / Snapshots
-> Ingest API
-> PostgreSQL + Blob Storage
-> AI Analysis Worker / Backend AI Module
-> Azure AI Foundry or equivalent Azure AI service
-> Incident Detection + Root Cause Explanation + Suggestions
-> PostgreSQL
-> Backend API
-> Frontend Incidents Tab / AI Suggestions Tab
```

Do not place Azure AI in the user request path.

Do not show Azure AI directly connecting to customer Kubernetes clusters.

AI should not automatically apply fixes in the initial version:

```text
AI suggests
-> User reviews
-> User approves
-> Fix application is future work
```

AI security notes:

```text
AI only processes already-ingested data.
AI processing must be scoped by organization_id, cluster_id, and resource_id.
Do not leak logs or incident data between tenants.
Do not send secrets, tokens, kubeconfigs, or credentials to AI models.
Redact sensitive values from logs before AI processing where possible.
Store AI-generated incidents and suggestions with tenant isolation.
Keep prompt/context templates versioned and controlled.
Log AI requests safely without exposing sensitive payloads.
```

## Gateway And Routing

Inside AKS, show kgateway / Kubernetes Gateway API routing.

HTTPRoutes:

```text
/                         -> clustersage-frontend
/api/auth/*               -> clustersage-backend
/api/agent-keys/*         -> clustersage-backend
/api/agent/*              -> clustersage-backend
/api/ingest/*             -> clustersage-backend / ingest API
/api/clusters/*           -> clustersage-backend
/api/audit/*              -> clustersage-backend
/api/incidents/*          -> clustersage-backend / future incident APIs
/api/ai-suggestions/*     -> clustersage-backend / future AI suggestion APIs
/health                   -> clustersage-backend health endpoint
```

Do not show the frontend directly connecting to databases, Storage, Service Bus, Key Vault, or AI services.

Frontend should communicate with backend APIs only.

## AKS Runtime Components

Inside production AKS, show:

```text
namespace: clustersage
  kgateway / Gateway API
  clustersage-frontend
  clustersage-backend API + ingest
  clustersage-email-worker
  clustersage-ai-worker (future/planned)
  clustersage-migrations
  ServiceAccount using AKS Workload Identity
```

The backend handles:

```text
User registration/login
JWT validation
Organization/tenant scoping
Agent registration
Agent key management
Agent heartbeat
Logs/events/snapshot ingestion
Cluster metadata
Resource metadata
Issue APIs
Future incident APIs
Future AI suggestion APIs
Audit logs
Service Bus event publishing
```

The email worker handles:

```text
Cluster connected email
Future notification emails
Service Bus queue consumption
Azure Communication Services Email sending
```

The future AI worker handles:

```text
AI incident detection
Error analysis
Root cause explanation
AI-generated remediation suggestions
Severity classification
Storing AI results
```

## Network Security

Show production security clearly:

```text
Azure Front Door is the primary public SaaS entry point.
WAF protects browser and agent traffic.
Bot protection and rate limiting are enabled at the edge.
kgateway LoadBalancer is used as the Front Door origin.
Backend services are not directly exposed to the internet.
Frontend does not directly access databases or Azure data services.
Customer clusters do not allow inbound access from ClusterSage.
Private endpoints are recommended/enabled for production data services.
```

Private endpoints should be shown for production where appropriate:

```text
PostgreSQL
Blob Storage
Key Vault
Service Bus
ACR, if private image pull is required later
```

For dev, lower-cost settings may be used.

For production, show the more secure target version.

## Non-Prod And Prod Isolation

Show two subscriptions clearly:

```text
clustersage-nonprod
  dev
  staging

clustersage-prod
  production runtime
  production data
  production monitoring
  production secrets
```

Important isolation rules:

```text
Dev and staging may use lower-cost settings.
Staging should be production-like where practical.
Production runtime must not be shared with non-prod.
Production data must not be shared with non-prod.
Production secrets must not be shared with non-prod.
Production observability should be separate from non-prod.
Only safe build-plane resources may be shared.
```

## Observability And Governance

Show:

```text
Application Insights
Log Analytics Workspace
Azure Monitor
Diagnostic Settings
Audit logs
WAF logs
Front Door access logs
AKS logs
Container logs
Service Bus metrics
Service Bus dead-letter count
PostgreSQL metrics
Storage metrics
Email worker logs
Future AI analysis metrics
Azure Policy / budgets / governance note
```

Production observability must be separate from non-prod observability.

Audit logs should track:

```text
User registration/login
Agent key creation/revocation
Cluster connection
Agent registration
Heartbeat
Data ingestion
Issue or future incident generation
Future AI suggestion generation
Email notification events
Admin/security actions
```

## Visual Design Requirements

Make the diagram visually clean and presentation-ready.

Use:

```text
Proper grouping boxes
Swimlanes
Consistent Azure-style icons
Consistent icon sizes
Consistent spacing
Orthogonal connectors
Minimal crossing lines
Clear arrow directions
Short readable labels
Consistent ClusterSage naming
A legend for flow types
```

Use different line styles or colors for:

```text
User/browser HTTPS traffic
Customer agent outbound ingestion
Internal API traffic
Data plane traffic
Service Bus/email flow
Future AI analysis flow
CI/CD deployment flow
Managed Identity / Workload Identity flow
Observability flow
```

Avoid:

```text
Too many long text boxes
Extremely wide rows
Overlapping connectors
Tiny unreadable text
Repeating the same full details in dev, staging, and prod
Mixing CI/CD, prod runtime, customer agent flow, AI flow, and legend into one crowded horizontal canvas
```

## Diagram Refinement Rules

Do not change the actual architecture meaning.

Do not remove important components.

Do not make the architecture less secure.

Do not show direct inbound traffic into customer clusters.

Do not show AI services directly connecting to customer clusters.

Do not show the frontend directly accessing the database.

Do not show users directly accessing backend pods.

Do not show public access to PostgreSQL, Key Vault, Service Bus, Blob Storage, or AI services in production unless explicitly marked as a current temporary gap.

Do not show Entra ID as the end-user login system.

In this architecture:

```text
End-user login = app-native email/password + JWT
Entra ID = Azure workload identity, infrastructure identity, and CI/CD identity
```

Do not rename actual deployed resource IDs unless the diagram label is intentionally showing target clean naming. If legacy deployed names are relevant, put them in a note.

## Final Output Required

After modifying the diagram, provide:

1. A short explanation of what was changed.
2. The refined architecture flow.
3. A list of pages or sections created.
4. A list of components renamed for ClusterSage consistency.
5. A list of confusing parts that were cleaned.
6. Where future AI capability was added.
7. How future AI incident detection and suggestions flow through the system.
8. How traffic flows from users to the application.
9. How customer cluster agent data reaches ClusterSage.
10. How email notifications work.
11. How identity is separated between app users and Azure resources.
12. How the 2-subscription environment isolation is represented.
13. Any architecture assumptions made.
14. Confirmation that the core architecture was not changed, only visually refined and clarified.
