# Agent Install Guide

The customer-installed agent runs inside the customer cluster and only connects outbound to the ClusterSage backend.

## Metrics Server Requirement For Runtime Metrics

ClusterSage can now ingest pod and node CPU/memory usage through the Kubernetes Metrics API, but that data only exists if the customer cluster has Metrics Server installed and healthy.

If Metrics Server is missing:

- the agent still installs and runs
- logs, snapshots, incidents, and AI features continue to work
- runtime CPU/memory metrics are skipped gracefully
- future dashboard runtime charts will remain unavailable

Quick verification:

```bash
kubectl top pods -A
kubectl top nodes
```

If those commands fail, the cluster does not currently expose the Metrics API the agent needs.

## Required Values

```yaml
backend:
  url: "https://nexaflow.site"
auth:
  email: "owner@example.com"
  accessKey: "cw_live_copy_from_dashboard"
cluster:
  name: "prod-aks-01"
  provider: "aks"
agent:
  image:
    repository: "acrclustersage.azurecr.io/clustersage-agent"
    tag: "stable"
  metrics:
    enabled: true
    intervalSeconds: 60
```

- `backend.url`: public SaaS API URL.
- `auth.email`: dashboard user email for tenant lookup.
- `auth.accessKey`: one-time agent key generated in dashboard.
- `cluster.name`: display name and unique cluster name within the organization.
- `agent.image.repository`: collector image registry/repository.
- `agent.metrics.enabled`: enables read-only Metrics API polling for pod/node CPU and memory samples.
- `agent.metrics.intervalSeconds`: frequency for metrics collection.

The image registry must be a real, resolvable ACR login server. If Kubernetes shows `lookup <registry>.azurecr.io ... no such host`, the registry hostname in the values file is wrong or the customer cluster cannot resolve public DNS.

## Public Agent Image Pull

The ClusterSage agent image is published with anonymous pull enabled. Customer clusters do not need Docker login or Kubernetes image pull secrets for the default image.

```bash
docker pull acrclustersage.azurecr.io/clustersage-agent:stable
crictl pull acrclustersage.azurecr.io/clustersage-agent:stable
```

Use `stable` for normal installs. The image publishing workflow also pushes immutable version and commit tags for rollback/debugging.

## Install

```bash
helm upgrade --install clusterwatch-agent ./repos/ClusterSage-helm/charts/clusterwatch-agent \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

For customer installs, use the published OCI Helm chart:

```bash
helm upgrade --install clusterwatch-agent oci://acrclustersage.azurecr.io/helm/clusterwatch-agent \
  --version 0.1.2 \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

To correct an existing install with a bad image registry:

```bash
helm upgrade clusterwatch-agent oci://acrclustersage.azurecr.io/helm/clusterwatch-agent \
  --version 0.1.2 \
  --namespace clusterwatch-agent \
  --reuse-values \
  --set agent.image.repository="acrclustersage.azurecr.io/clustersage-agent" \
  --set agent.image.tag="stable"
```

## Verify

```bash
kubectl get pods -n clusterwatch-agent
kubectl logs deploy/clusterwatch-collector -n clusterwatch-agent
kubectl get daemonset clusterwatch-fluent-bit -n clusterwatch-agent
curl https://nexaflow.site/health
```

## Troubleshoot

```bash
kubectl describe pod -n clusterwatch-agent -l app.kubernetes.io/component=collector
kubectl logs -n clusterwatch-agent -l app.kubernetes.io/component=fluent-bit
kubectl auth can-i list pods --as system:serviceaccount:clusterwatch-agent:clusterwatch-agent --all-namespaces
nslookup acrclustersage.azurecr.io
```

## Uninstall

```bash
helm uninstall clusterwatch-agent -n clusterwatch-agent
kubectl delete namespace clusterwatch-agent
```
