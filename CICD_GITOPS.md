# ClusterSage CI/CD And GitOps

## Overview

ClusterSage uses an immutable-image GitOps flow:

1. Pull requests validate code and run security scans.
2. A push to `main` builds the changed application image once.
3. That workflow pushes the image to ACR and captures the pushed digest.
4. The workflow updates the dev GitOps values file with both the readable tag and the immutable digest.
5. ArgoCD dev auto-sync applies the dev values change.
6. Staging promotion copies the exact repository, tag, and digest from dev into staging.
7. Production promotion reads only from staging, pulls the exact staged digest, pushes a semantic release tag such as `v1.0.0` to the same image, and writes the release tag plus the same digest into prod.

This keeps staging and prod on the same artifact that was already built and published earlier.

## Repositories Involved

- `ClusterSage-frontend`: frontend app validation and image publish
- `ClusterSage-services`: platform API, email worker, and collector agent validation and image publish
- `ClusterSage-helm`: digest-aware image rendering
- `ClusterSage-gitops`: environment values targeted by promotion pull requests

## What Gets Promoted

The platform GitOps flow manages:

- `frontend.image`
- `backend.image`
- `emailWorker.image`
- `migrationJob.image`

The migration job intentionally follows the backend image artifact.

The collector agent image is published from `ClusterSage-services`, but it is not part of the platform ArgoCD environment promotion flow because customers install it into their own clusters.

## Values Shape

The environment overlay values files now support:

```yaml
frontend:
  image:
    repository: acrclustersage.azurecr.io/clustersage/frontend
    tag: 2486e08
    digest: sha256:...
```

The same structure exists for backend, email worker, and migration job.

## Helm Rendering

The platform chart renders images this way:

- if `digest` is present: `repository@digest`
- otherwise: `repository:tag`

That means GitOps promotion can rely on the digest as the deployment source of truth while keeping a readable tag in Git. In prod, that readable tag is a human release label such as `v1.0.0`.

## Pull Request Validation

### Frontend

Workflow:

- `repos/ClusterSage-frontend/.github/workflows/pr-validation.yml`

Runs:

- `npm ci`
- `npm run lint`
- `npm run typecheck --if-present`
- `npm run test --if-present`
- `npm run build`
- SonarQube scan
- Snyk dependency scan

### Services

Workflows:

- `repos/ClusterSage-services/.github/workflows/pr-validation-platform-api.yml`
- `repos/ClusterSage-services/.github/workflows/pr-validation-email-worker.yml`
- `repos/ClusterSage-services/.github/workflows/pr-validation-collector-agent.yml`

Runs:

- dependency install per service
- `python -m compileall app`
- `pytest` where tests exist
- Docker build validation for each service
- SonarQube scan
- Snyk dependency scan

## Dev Deployment Flow

### Frontend

Workflow:

- `repos/ClusterSage-frontend/.github/workflows/publish-image.yml`
- `repos/ClusterSage-frontend/.github/workflows/promote-staging.yml`
- `repos/ClusterSage-frontend/.github/workflows/promote-prod.yml`

Behavior:

- validates frontend
- logs into Azure using GitHub OIDC
- pushes image to ACR with the automatic short SHA tag
- captures the pushed digest from `docker/build-push-action`
- updates `ClusterSage-gitops/environments/dev/values/clustersage-values.yaml`
- commits only that values-file change

### Platform API

Workflows:

- `repos/ClusterSage-services/.github/workflows/pr-validation-platform-api.yml`
- `repos/ClusterSage-services/.github/workflows/publish-platform-api.yml`
- `repos/ClusterSage-services/.github/workflows/promote-staging-platform-api.yml`
- `repos/ClusterSage-services/.github/workflows/promote-prod-platform-api.yml`

Behavior:

- validates platform API
- pushes backend image to ACR
- captures digest
- updates dev backend image fields
- updates dev migration job image fields to the same artifact

### Email Worker

Workflows:

- `repos/ClusterSage-services/.github/workflows/pr-validation-email-worker.yml`
- `repos/ClusterSage-services/.github/workflows/publish-email-worker.yml`
- `repos/ClusterSage-services/.github/workflows/promote-staging-email-worker.yml`
- `repos/ClusterSage-services/.github/workflows/promote-prod-email-worker.yml`

Behavior:

- validates email worker
- pushes image to ACR
- captures digest
- updates dev email worker image fields

### Collector Agent

Workflows:

- `repos/ClusterSage-services/.github/workflows/pr-validation-collector-agent.yml`
- `repos/ClusterSage-services/.github/workflows/publish-collector-agent.yml`

Behavior:

- validates collector agent
- pushes the agent image
- keeps the current customer-facing `stable` tag in addition to the immutable SHA tag

The collector agent does not update platform GitOps values and does not have staging/prod promotion workflows because there is no environment-specific ArgoCD values target for it in this repository.

## Staging Promotion Flow

Workflow:

- `repos/ClusterSage-frontend/.github/workflows/promote-staging.yml`
- `repos/ClusterSage-services/.github/workflows/promote-staging-platform-api.yml`
- `repos/ClusterSage-services/.github/workflows/promote-staging-email-worker.yml`

Behavior:

- manual `workflow_dispatch`
- requires a typed confirmation input with the exact value `promote-to-staging`
- reads repository, tag, and digest from:
  - `environments/dev/values/clustersage-values.yaml`
- validates that digest exists and matches `sha256:...`
- copies the same values into:
  - `environments/staging/values/clustersage-values.yaml`
- creates a GitOps promotion branch and opens a PR to `main`
- deployment happens only after that PR is reviewed and merged

No rebuild happens in staging promotion.

## Production Promotion Flow

Workflow:

- `repos/ClusterSage-frontend/.github/workflows/promote-prod.yml`
- `repos/ClusterSage-services/.github/workflows/promote-prod-platform-api.yml`
- `repos/ClusterSage-services/.github/workflows/promote-prod-email-worker.yml`

Behavior:

- manual `workflow_dispatch`
- requires a `release_version` input in the exact format `vMAJOR.MINOR.PATCH`
- examples allowed:
  - `v1.0.0`
  - `v1.2.3`
  - `v2.10.4`
- reads repository, current staging tag, and digest only from:
  - `environments/staging/values/clustersage-values.yaml`
- fails if the staging values file is missing
- fails if the staging digest is missing or not in `sha256:...` format
- fails if the release version does not match the semantic version format
- logs into Azure using GitHub OIDC
- logs into ACR
- pulls the exact staged image by digest
- pushes the semantic production release tag to that same image without rebuilding it
- writes the prod values so:
  - `tag` becomes the semantic release label like `v1.0.0`
  - `digest` stays the exact staged digest
- copies the same repository plus the new release tag and existing digest into:
  - `environments/prod/values/clustersage-values.yaml`
- creates a GitOps promotion branch and opens a PR to `main`
- deployment happens only after that PR is reviewed and merged

No rebuild happens in prod promotion. Prod can only promote from staging, never directly from dev or `main`.

Important prerequisite:

- the staging values file must already contain a real image digest from a successful dev-to-staging promotion
- placeholder staging tags or empty staging digests will cause prod promotion to fail by design

## ArgoCD Behavior

Current application/value wiring:

- dev application uses `values-dev.yaml` plus `environments/dev/values/clustersage-values.yaml`
- staging application uses `values-staging.yaml` plus `environments/staging/values/clustersage-values.yaml`
- prod application uses `values-prod.yaml` plus `environments/prod/values/clustersage-values.yaml`

Current sync posture:

- dev: auto-sync enabled with `prune`, `selfHeal`, and `allowEmpty: false`
- staging: auto-sync enabled with `prune`, `selfHeal`, and `allowEmpty: false`
- prod: auto-sync enabled with `prune`, `selfHeal`, and `allowEmpty: false`

This does not bypass promotion control:

- dev still updates from main-branch publish workflows
- staging still deploys only after a promotion PR is reviewed and merged
- prod still deploys only after a promotion PR is reviewed and merged

## Rollback

Rollback is Git-based.

Minimum rollback path:

1. Find the values-file commit that changed the bad deployment.
2. Revert that commit.
3. Push the revert.
4. ArgoCD reconciles back to the previous digest.

Example:

```bash
git revert <commit-sha>
git push origin main
```

For prod, rollback should restore a previous known-good version tag and digest pair in:

- `repos/ClusterSage-gitops/environments/prod/values/clustersage-values.yaml`

## Required GitHub Variables

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `ACR_NAME`
- `ACR_LOGIN_SERVER`
- `ACR_FRONTEND_REPOSITORY`
- `ACR_PLATFORM_API_REPOSITORY`
- `ACR_EMAIL_WORKER_REPOSITORY`
- `ACR_COLLECTOR_AGENT_REPOSITORY`

## Required GitHub Secrets

- `AZURE_CLIENT_ID` if you keep Azure identity values in secrets instead of variables
- `AZURE_TENANT_ID` if you keep Azure identity values in secrets instead of variables
- `AZURE_SUBSCRIPTION_ID` if you keep Azure identity values in secrets instead of variables
- `GITOPS_REPO_TOKEN`
- `SONAR_TOKEN`
- `SONAR_HOST_URL`
- `SNYK_TOKEN`

## Required Azure Permissions

The federated GitHub identity used by the build workflows needs:

- `AcrPush` on the Azure Container Registry

No Kubernetes credentials are needed by these workflows because deployment happens through Git commits and ArgoCD reconciliation.

## Troubleshooting

### Promotion workflow says digest is missing

The source environment values file was not updated by a successful main-branch image publish yet, or a previous manual edit removed the digest field.

### Production workflow says release version is invalid

The supplied `release_version` must exactly match:

- `vMAJOR.MINOR.PATCH`

Examples:

- `v1.0.0`
- `v1.2.3`
- `v2.10.4`

### Build workflow pushes image but GitOps file does not change

Check:

- `GITOPS_REPO_TOKEN`
- target values path
- yq installation step
- branch protection or token push permissions on `ClusterSage-gitops`

### SonarQube or Snyk steps are skipped on fork PRs

That is expected. GitHub does not pass repository secrets to forked pull requests.

## Why This Design

This version avoids GitHub Environments completely while keeping promotions deliberate:

- promotions are still manual
- staging can only promote what is already in dev
- prod can only promote what is already in staging
- the operator must provide an exact semantic release label before prod promotion proceeds
- the workflow opens a GitOps PR instead of pushing directly to `main`
- normal GitHub PR review and branch protection can be used as the approval gate
- the deployed artifact is still pinned by digest, so no environment rebuild drift is introduced
- the prod version tag is only a human release label; the digest remains the immutable deployed artifact
