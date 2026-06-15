# Helm Charts

Current chart paths:

- Platform: `repos/ClusterSage-helm/charts/clustersage`
- Customer agent: `repos/ClusterSage-helm/charts/clusterwatch-agent`

Validate locally when Helm is installed:

```bash
helm lint repos/ClusterSage-helm/charts/clustersage
helm template clustersage-dev repos/ClusterSage-helm/charts/clustersage -n clustersage -f repos/ClusterSage-helm/charts/clustersage/values-dev.yaml
helm template clustersage-staging repos/ClusterSage-helm/charts/clustersage -n clustersage -f repos/ClusterSage-helm/charts/clustersage/values-staging.yaml
helm template clustersage-prod repos/ClusterSage-helm/charts/clustersage -n clustersage -f repos/ClusterSage-helm/charts/clustersage/values-prod.yaml
helm lint repos/ClusterSage-helm/charts/clusterwatch-agent
helm template clusterwatch-agent repos/ClusterSage-helm/charts/clusterwatch-agent -n clusterwatch-agent -f repos/ClusterSage-helm/charts/clusterwatch-agent/values.customer.example.yaml
```

Platform deployment is performed by ArgoCD/GitOps, not by direct production Helm upgrades.
