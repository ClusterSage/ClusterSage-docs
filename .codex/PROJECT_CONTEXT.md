# Project Context

ClusterWatch is a multi-tenant Kubernetes/AKS observability SaaS using the customer-installed agent model. The current repository implements a complete first production scaffold: FastAPI backend, Next.js frontend, Python collector, customer agent Helm chart, platform Helm chart, Docker Compose, Kubernetes manifests, Azure deployment runbooks, and smoke tests.

Do not change the architecture to Azure Lighthouse, direct tenant scanning, or automatic customer subscription access. The agent must run in the customer cluster and push data outward.
