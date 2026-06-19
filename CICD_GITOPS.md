# ClusterSage CI/CD And GitOps

## Overview

ClusterSage uses an immutable-image GitOps flow:

1. Pull requests validate code and run security scans.
2. A push to `main` builds the changed application image once.
3. That workflow pushes the image to ACR and captures the pushed digest.
4. The workflow updates the dev GitOps values file with both the readable tag and the immutable digest.
5. ArgoCD dev auto-sync applies the dev values change.
6. Staging promotion copies the exact repository, tag, and digest from dev into staging.
7. Production promotion copies the exact repository, tag, and digest from staging into prod.

This keeps staging and prod on the same artifact that was already built and published earlier.

## Repositories Involved

- `ClusterSage-frontend`: frontend app validation and image publish
- `ClusterSage-services`: platform API, email worker, and collector agent validation and image publish
- `ClusterSage-helm`: digest-aware image rendering
- `ClusterSage-gitops`: environment values and promotion workflows

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

That means GitOps promotion can rely on the digest as the deployment source of truth while keeping a readable tag in Git.

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

Workflow:

- `repos/ClusterSage-services/.github/workflows/pr-validation.yml`

Runs:

- dependency install per service
- `python -m compileall app`
- `pytest` where tests exist
- offline Alembic SQL rendering for `platform-api`
- Docker build validation for each service
- SonarQube scan
- Snyk dependency scan

## Dev Deployment Flow

### Frontend

Workflow:

- `repos/ClusterSage-frontend/.github/workflows/publish-image.yml`

Behavior:

- validates frontend
- logs into Azure using GitHub OIDC
- pushes image to ACR with the 7-character commit SHA tag
- captures the pushed digest from `docker/build-push-action`
- updates `ClusterSage-gitops/environments/dev/values/clustersage-values.yaml`
- commits only that values-file change

### Platform API

Workflow:

- `repos/ClusterSage-services/.github/workflows/publish-platform-api.yml`

Behavior:

- validates platform API
- pushes backend image to ACR
- captures digest
- updates dev backend image fields
- updates dev migration job image fields to the same artifact

### Email Worker

Workflow:

- `repos/ClusterSage-services/.github/workflows/publish-email-worker.yml`

Behavior:

- validates email worker
- pushes image to ACR
- captures digest
- updates dev email worker image fields

### Collector Agent

Workflow:

- `repos/ClusterSage-services/.github/workflows/publish-collector-agent.yml`

Behavior:

- validates collector agent
- pushes the agent image
- keeps the current customer-facing `stable` tag in addition to the immutable SHA tag

The collector agent does not update platform GitOps values.

## Staging Promotion Flow

Workflow:

- `repos/ClusterSage-gitops/.github/workflows/promote-staging.yml`

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

- `repos/ClusterSage-gitops/.github/workflows/promote-prod.yml`

Behavior:

- manual `workflow_dispatch`
- requires a typed confirmation input with the exact value `promote-to-prod`
- reads repository, tag, and digest from:
  - `environments/staging/values/clustersage-values.yaml`
- validates that digest exists and matches `sha256:...`
- copies the same values into:
  - `environments/prod/values/clustersage-values.yaml`
- creates a GitOps promotion branch and opens a PR to `main`
- deployment happens only after that PR is reviewed and merged

No rebuild happens in prod promotion.

## ArgoCD Behavior

Current application/value wiring:

- dev application uses `values-dev.yaml` plus `environments/dev/values/clustersage-values.yaml`
- staging application uses `values-staging.yaml` plus `environments/staging/values/clustersage-values.yaml`
- prod application uses `values-prod.yaml` plus `environments/prod/values/clustersage-values.yaml`

Current sync posture preserved:

- dev: auto-sync enabled
- staging: no automated sync block currently defined in the manifest
- prod: automated sync currently enabled and preserved as-is

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

For prod, rollback should restore a previous known-good digest in:

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
- the operator must type an exact confirmation phrase before the workflow proceeds
- the workflow opens a GitOps PR instead of pushing directly to `main`
- normal GitHub PR review and branch protection can be used as the approval gate
- the deployed artifact is still pinned by digest, so no environment rebuild drift is introduced
