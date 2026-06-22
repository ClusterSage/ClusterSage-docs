# Capstone Evaluation Checklist

Based on:

- `freshers_final_captsone_evaluation.pdf`
- current repository state only

Legend:

- `[x]` Done
- `[~]` Partially done / implemented differently / needs live proof
- `[ ]` Not done or not visible in repo

## Infrastructure as Code

- `[x]` Terraform is used as the primary IaC tool.
- `[x]` Infra is modularized with reusable modules for AKS, networking, storage, postgres, service bus, key vault, front door, monitoring, workload identity, and related components.
- `[x]` AKS environment roots exist for `dev`, `staging`, and `prod`.
- `[x]` AKS autoscaling support exists.
- `[x]` System and user node pool support exists in Terraform.
- `[x]` Azure Container Registry is provisioned and consumed.
- `[x]` Managed cloud services are provisioned via Terraform: Storage, PostgreSQL, Service Bus, Key Vault, Email, monitoring, and AI Foundry.
- `[x]` Azure Workload Identity / federated identity credential is provisioned in Terraform.
- `[x]` Application Insights / monitoring module exists.
- `[x]` Remote state backend is configured with Azure Storage backend files in env roots.
- `[x]` `terraform fmt` and `terraform validate` are wired into CI.
- `[x]` Resources are tagged with `Environment`.
- `[x]` Resources appear to be tagged with `Owner`.
- `[x]` `.gitignore` excludes `*.tfstate`, `*.tfvars`, plan files, and Terraform caches.
- `[x]` Outputs expose useful infra/runtime values such as ACR login server, storage account/container, service bus namespace, key vault URI, identity client ID, and front door hostnames.
- `[~]` “No hardcoded values” is only partially true; variables are used heavily, but some defaults and names are still hardcoded.
- `[~]` Direct cluster endpoint / kube credential outputs are not clearly exposed as Terraform outputs.
- `[~]` Live proof that `terraform validate` currently passes in all roots is not visible from repo alone.
- `[~]` The evaluator wording expects public and private subnets; the repo clearly has VNet/subnets, but exact mapping to that wording needs live explanation.

## Kubernetes Deployment and Configuration

- `[x]` The app is containerized and deployed to Kubernetes through Helm and GitOps.
- `[x]` There are at least 2 independent services in the platform: `platform-api` and `email-worker`.
- `[x]` Frontend and backend are configured with more than 1 replica by default.
- `[x]` Backend has liveness, readiness, and startup probes.
- `[x]` Frontend has liveness, readiness, and startup probes.
- `[x]` CPU and memory requests/limits match the required thresholds: `100m/128Mi` requests and `500m/512Mi` limits.
- `[x]` A dedicated ServiceAccount exists for workloads.
- `[x]` ServiceAccount annotations support Azure Workload Identity.
- `[x]` Secrets are handled through Kubernetes Secret and also through Key Vault CSI / `SecretProviderClass`.
- `[x]` External access is implemented via Gateway API / `HTTPRoute`.
- `[x]` Namespace isolation exists and does not use `default`.
- `[~]` Namespace is `clustersage`, not literally `production`.
- `[~]` The evaluator expects a `kubernetes/` raw manifest folder; this repo uses Helm/GitOps instead.
- `[~]` `email-worker` has only `1` replica by default, so this may be a gap if every microservice is expected to run with more than one replica.
- `[ ]` Health probe paths do not match the PDF exactly. The PDF asks for `/healthz` and `/ready`; the repo currently uses `/health` and `/`.
- `[ ]` A backend `/ready` endpoint is not visible.
- `[ ]` Live proof of `kubectl apply --dry-run=client`, running pods, EXTERNAL-IP assignment, and 200 OK health checks cannot be confirmed from repo alone.

## GitHub Actions CI/CD

- `[x]` GitHub Actions workflows exist for CI/CD.
- `[x]` Frontend PR validation workflow exists.
- `[x]` Service PR validation workflows exist for platform API, email worker, and collector agent.
- `[x]` Terraform PR and apply workflows exist.
- `[x]` Image publish workflows exist for frontend, platform API, email worker, and collector agent.
- `[x]` Promotion workflows exist for staging and prod.
- `[x]` Azure authentication uses OIDC in workflows.
- `[x]` Secrets and variables are referenced rather than hardcoded in workflows.
- `[x]` Build pipelines install dependencies, run tests/checks, build images, and push to ACR.
- `[x]` Trivy image scanning is present in publish workflows.
- `[x]` SonarQube and Snyk are present in PR validation workflows.
- `[x]` Terraform pipeline produces plans and uploads artifacts for review.
- `[x]` Promotion to staging and prod has manual gating through `workflow_dispatch` inputs.
- `[x]` GitOps-based promotion avoids direct production `kubectl apply`.
- `[~]` The deployment model is GitOps/ArgoCD, not the exact `deploy.yml` flow described in the PDF.
- `[~]` GitOps CI currently validates YAML, but full Helm render validation is not clearly present in the actual workflow file.
- `[~]` “Require manual approval” is only partially met. Staging/prod promotions have manual input gates, but Terraform apply still uses `-auto-approve` once triggered.
- `[ ]` The PDF asks for three specifically named workflows: `build.yml`, `deploy.yml`, and `terraform-apply.yml`; the repo uses a split workflow model instead.
- `[ ]` The PDF says image scanning should fail on High/Severe issues. Current Trivy steps use `continue-on-error: true`, so the scan is not a hard gate.
- `[ ]` “All 3 workflows have successful recent executions” cannot be verified from repo contents alone.
- `[ ]` Smoke tests after deployment are not clearly visible in the current workflows.
- `[ ]` A single deploy workflow that gets cluster credentials, updates manifests, applies them with `kubectl`, verifies rollout, and runs smoke tests is not present because ArgoCD replaces that model.

## Cloud Integration and Pod to Resource Communication

- `[x]` Azure Workload Identity is clearly part of the architecture.
- `[x]` ServiceAccount annotation with workload identity client ID is present in GitOps values.
- `[x]` Federated identity credential is created in Terraform.
- `[x]` Role assignments exist for Service Bus, Storage Blob, Key Vault, and OpenAI access.
- `[x]` Email worker supports `DefaultAzureCredential`.
- `[x]` Platform notification publishing supports either connection string or `DefaultAzureCredential`.
- `[x]` AI integration supports managed identity auth via `DefaultAzureCredential`.
- `[x]` Event-driven integration exists via Azure Service Bus between services.
- `[~]` Cloud integration is only partially compliant with the “no static credentials” rule because blob storage code currently requires `AZURE_STORAGE_CONNECTION_STRING`.
- `[~]` Email and Service Bus support Workload Identity fallback, but connection-string paths still remain enabled.
- `[~]` Secrets are not hardcoded in manifests, but some integrations still rely on secret material instead of identity-only access.
- `[ ]` The strict rubric requirement says no secrets containing access keys for the managed service used in the demo path. If blob storage is part of the demo path, this is not fully met.
- `[ ]` Live proof of successful pod reads/writes to managed services is not verifiable from repo alone.

## Security and Code Quality

- `[x]` Dockerfiles are multistage for frontend, platform API, email worker, and collector agent.
- `[x]` Runtime containers run as non-root users.
- `[x]` Kubernetes Secrets are used for sensitive config.
- `[x]` ServiceAccount/RBAC objects exist.
- `[x]` Container image scanning exists.
- `[~]` RBAC is present, but least-privilege across all charts is not fully audited here.
- `[~]` No obvious real credentials are visible in the repo snapshot, but git history was not audited in this checklist.
- `[ ]` `.gitignore` does not explicitly ignore `.env` files, so it is not fully aligned with the stricter PDF wording.
- `[ ]` Security gate enforcement is incomplete because image scanning does not currently block the pipeline on high/critical findings.

## Bonus Items

- `[x]` Event-driven architecture: Service Bus between platform API and email worker.
- `[x]` AI integration: Azure AI Foundry / Azure OpenAI integration exists.
- `[x]` GitOps deployment: ArgoCD + GitOps repo are in place.
- `[~]` API documentation likely exists through FastAPI `/docs` and `/openapi.json`, but it was not verified as a formal deliverable here.
- `[~]` Disaster recovery support appears partially present in infra design, but tested backup/restore proof is not visible from repo alone.
- `[ ]` Advanced monitoring with Prometheus + Grafana is not clearly present.
- `[ ]` Cost estimation in Terraform outputs is not visible.
- `[ ]` NetworkPolicy resources are not clearly present.
- `[ ]` Multi-region deployment is not clearly implemented.

## Biggest Gaps for Evaluation

- `[ ]` Exact deploy pipeline expected by the PDF is not present because the repo uses GitOps instead of a `kubectl apply` deployment workflow.
- `[ ]` Trivy scan is not a blocking security gate.
- `[ ]` Backend health endpoints do not match `/healthz` and `/ready`.
- `[ ]` Blob storage integration still uses a connection string, so identity-only cloud access is not fully achieved.
- `[ ]` `.gitignore` does not explicitly exclude `.env`.
- `[ ]` Terraform apply does not show a true approval gate in workflow YAML.
- `[ ]` Live validation items remain unproven from code alone: successful recent workflow runs, reachable app, running pods, external IP, rollout checks, smoke tests, and managed-service access demo.

## Overall Assessment

- `[~]` Strong on architecture, infra modularity, AKS, GitOps, OIDC, ArgoCD, ACR, and multi-service design.
- `[~]` Only partially aligned with the evaluator’s exact checklist because the implementation is more GitOps-oriented than the prescribed raw deploy-pipeline model.
- `[~]` Likely a solid partial / good submission with a few compliance gaps rather than a perfect checklist pass.
