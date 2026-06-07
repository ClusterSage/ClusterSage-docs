# AI Context For KubeSage

The product name is KubeSage. Frontend-visible branding must use KubeSage only. Do not rename internal folders, Helm release names, database tables, environment variables, or Kubernetes resources just to satisfy UI branding.

KubeSage uses a customer-installed, read-only in-cluster agent. The SaaS backend does not scan customer Azure subscriptions. Users must only see their own organization, clusters, resources, logs, issues, and audit data.

Cluster resource pages are resource-centric. After selecting a cluster, users see Kubernetes resources. Selecting a resource opens a detail page with these tabs:

- Details
- Logs
- Incidents
- AI Suggestions

Details is the default tab. Logs are resource-scoped, currently pod-first. Incidents and AI Suggestions are placeholders for future AI releases and must not contain fake AI output.

Cluster connection email is event-driven. The API publishes a Service Bus message after successful agent registration. The email worker consumes the message and sends Azure Communication Services Email. Email failures must not break cluster connection.

Azure infrastructure is managed with Terraform in `terraform/`. Preferred Azure patterns are Managed Identity, Key Vault, Service Bus, Front Door WAF, secure session handling, tenant authorization, and backend-enforced rate limiting.
