# Helm Charts

Current chart paths:

- Platform: `repos/ClusterSage-helm/charts/clustersage`
- Customer agent: `repos/ClusterSage-helm/charts/clusterwatch-agent`
- Published OCI chart version for the current customer install flow: `0.1.1`

Validate locally when Helm is installed:

```bash
helm lint repos/ClusterSage-helm/charts/clustersage
helm template clustersage-dev repos/ClusterSage-helm/charts/clustersage -n clustersage -f repos/ClusterSage-helm/charts/clustersage/values-dev.yaml
helm template clustersage-staging repos/ClusterSage-helm/charts/clustersage -n clustersage -f repos/ClusterSage-helm/charts/clustersage/values-staging.yaml
helm template clustersage-prod repos/ClusterSage-helm/charts/clustersage -n clustersage -f repos/ClusterSage-helm/charts/clustersage/values-prod.yaml
helm lint repos/ClusterSage-helm/charts/clusterwatch-agent
helm template clusterwatch-agent repos/ClusterSage-helm/charts/clusterwatch-agent -n clusterwatch-agent -f repos/ClusterSage-helm/charts/clusterwatch-agent/values.customer.example.yaml
helm template clusterwatch-agent repos/ClusterSage-helm/charts/clusterwatch-agent -n clusterwatch-agent --set backend.url=https://nexaflow.site --set auth.email=owner@example.com --set auth.accessKey=test-key --set cluster.name=test-cluster --set agent.image.repository=acrclustersage.azurecr.io/clustersage-agent --set remediation.enabled=true --set remediation.allowedNamespaces[0]=prod
helm template clusterwatch-agent repos/ClusterSage-helm/charts/clusterwatch-agent -n clusterwatch-agent --set backend.url=https://nexaflow.site --set auth.email=owner@example.com --set auth.accessKey=test-key --set cluster.name=test-cluster --set agent.image.repository=acrclustersage.azurecr.io/clustersage-agent --set remediation.enabled=true --set remediation.clusterWide=true
```

Platform deployment is performed by ArgoCD/GitOps, not by direct production Helm upgrades.

## Agent Remediation RBAC

The customer agent chart now supports optional remediation permissions.

Safe defaults:

- `remediation.enabled=false`
- `remediation.allowedNamespaces=[]`
- `remediation.clusterWide=false`

When remediation is disabled, no write RBAC is rendered and the agent remains read-only.

When remediation is enabled:

- namespace-scoped mode renders `Role` and `RoleBinding` objects only for the listed namespaces
- cluster-wide mode requires explicit `remediation.clusterWide=true`
- the only write capability granted is:
  - `apps/deployments`: `get`, `patch`
- the only extra read capability added for owner validation is:
  - `apps/replicasets`: `get`, `list`

The chart does not grant:

- cluster-admin
- wildcard verbs
- secrets access
- `pods/exec`
- workload delete permission
