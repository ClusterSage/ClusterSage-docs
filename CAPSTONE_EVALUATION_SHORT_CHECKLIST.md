
# Capstone Evaluation Short Checklist

Based on:

- `freshers_final_captsone_evaluation.pdf`
- current repository state only

Legend:

- `[x]` Done
- `[~]` Needs live demo proof or is partially aligned
- `[ ]` Not done

## Done

- `[x]` Terraform is used as the primary IaC tool.
- `[x]` Infra is modularized with reusable modules for AKS, networking, storage, postgres, service bus, key vault, monitoring, front door, and workload identity.
- `[x]` AKS environment roots exist for `dev`, `staging`, and `prod`.
- `[x]` AKS autoscaling support exists.
- `[x]` System and user node pool support exists.
- `[x]` Azure Container Registry is integrated.
- `[x]` Managed cloud services are provisioned through Terraform, including PostgreSQL, Storage, Service Bus, Key Vault, Email, and monitoring.
- `[x]` Azure Workload Identity / federated identity credential is provisioned in Terraform.
- `[x]` Remote Terraform state backend is configured with Azure Storage.
- `[x]` `terraform fmt` and `terraform validate` are wired into CI.
- `[x]` Resources are tagged with `Environment` and appear to include `Owner`.
- `[x]` `.gitignore` excludes Terraform state, tfvars, plan files, and cache artifacts.
- `[x]` There are at least 2 independent services in the platform: `platform-api` and `email-worker`.
- `[x]` Frontend and backend are configured with more than 1 replica.
- `[x]` Frontend and backend have health probes configured.
- `[x]` CPU and memory requests/limits match the evaluation thresholds.
- `[x]` Dedicated workload ServiceAccount exists.
- `[x]` ServiceAccount annotations support Azure Workload Identity.
- `[x]` Secrets are handled through Kubernetes Secrets and Key Vault CSI / `SecretProviderClass`.
- `[x]` External routing is implemented through Gateway API / `HTTPRoute`.
- `[x]` Namespace isolation exists and does not use `default`.
- `[x]` GitHub Actions workflows exist for CI/CD.
- `[x]` PR validation workflows exist for frontend, platform API, email worker, and collector agent.
- `[x]` Terraform PR/apply workflows exist.
- `[x]` Image publish workflows exist for frontend, platform API, email worker, and collector agent.
- `[x]` Promotion workflows exist for staging and prod.
- `[x]` Azure authentication uses OIDC in workflows.
- `[x]` Build pipelines install dependencies, run tests/checks, build images, and push to ACR.
- `[x]` Trivy image scanning is present.
- `[x]` SonarQube and Snyk are present in PR validation workflows.
- `[x]` Terraform plan artifacts are generated in CI.
- `[x]` Staging and prod promotion have manual workflow-dispatch gates.
- `[x]` Event-driven communication exists through Azure Service Bus.
- `[x]` AI integration exists through Azure AI Foundry / Azure OpenAI.
- `[x]` GitOps deployment exists with ArgoCD and a dedicated GitOps repo.
- `[x]` Dockerfiles are multistage.
- `[x]` Runtime containers run as non-root users.
- `[x]` ServiceAccount and RBAC resources exist.

## Needs Live Demo Proof or Partial Alignment

- `[~]` Terraform validation across all roots needs live proof from actual runs.
- `[~]` Public/private subnet wording may need explanation during evaluation.
- `[~]` Namespace is `clustersage`, not literally `production`.
- `[~]` The repo uses Helm/GitOps instead of the raw `kubernetes/` manifest structure requested in the PDF.
- `[~]` `email-worker` has only `1` replica by default.
- `[~]` The deployment model is GitOps/ArgoCD, not the exact `deploy.yml` imperative flow described in the PDF.
- `[~]` GitOps CI clearly validates YAML, but full Helm render validation is not obvious in the current workflow.
- `[~]` Manual gating exists, but Terraform apply still uses `-auto-approve` after trigger.
- `[~]` Email and Service Bus support Workload Identity fallback, but connection-string paths still exist.
- `[~]` Cloud integration proof needs a live demo showing pods successfully accessing managed services.
- `[~]` No obvious real credentials are visible in the repo snapshot, but git history was not audited here.
- `[~]` API documentation likely exists via FastAPI docs, but it was not checked as a formal deliverable.
- `[~]` Disaster recovery appears partially supported in infra design, but tested backup/restore proof is not visible from repo alone.
- `[~]` Workflow success history, rollout success, pod status, external reachability, and smoke-test proof all need live/demo evidence.

## Not Done

- `[ ]` Health endpoints do not match the PDF exactly: the repo does not clearly provide `/healthz` and `/ready`.
- `[ ]` A backend `/ready` endpoint is not visible.
- `[ ]` A raw `kubectl apply` deploy workflow that gets cluster credentials, updates manifests, applies them, verifies rollout, and runs smoke tests is not present.
- `[ ]` The exact workflow structure requested in the PDF as `build.yml`, `deploy.yml`, and `terraform-apply.yml` is not present in that form.
- `[ ]` Trivy scanning is not a hard blocking security gate because the scan uses `continue-on-error: true`.
- `[ ]` Blob storage integration still requires `AZURE_STORAGE_CONNECTION_STRING`, so identity-only cloud access is not fully achieved.
- `[ ]` `.gitignore` does not explicitly exclude `.env` files.
- `[ ]` Terraform apply does not show a true approval gate in workflow YAML.
- `[ ]` Advanced monitoring with Prometheus + Grafana is not clearly present.
- `[ ]` Cost estimation in Terraform outputs is not visible.
- `[ ]` NetworkPolicy resources are not clearly present.
- `[ ]` Multi-region deployment is not clearly implemented.
