# Agent Install Guide

The customer-installed agent runs inside the customer cluster and only connects outbound to the ClusterSage backend.

## Telemetry Add-ons

The customer chart can now install the telemetry pieces that the advanced dashboard needs:

- `kube-state-metrics` for Kubernetes object state, requests, limits, replica counts, and pod phase data
- optional `metrics-server` for live pod and node CPU/memory usage through the Kubernetes Metrics API
- the collector still pushes all telemetry outward to ClusterSage; ClusterSage does not pull into the customer cluster

Recommended default:

- enable `kube-state-metrics`
- keep `metrics-server` disabled if the cluster already has one
- enable `metrics-server` from the chart only when the customer cluster does not already expose `metrics.k8s.io`

If Metrics Server is missing and chart installation does not enable it:

- the agent still installs and runs
- logs, snapshots, incidents, and AI features continue to work
- runtime CPU/memory usage is skipped gracefully
- resource requests, limits, replica counts, and pod-phase telemetry still work through `kube-state-metrics`

Quick verification:

```bash
kubectl top pods -A
kubectl top nodes
```

If those commands fail, the cluster does not currently expose the Metrics API. In that case either install Metrics Server separately or set `addons.metricsServer.enabled=true` in the agent chart values.

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
    resourceUsage:
      enabled: true
    kubeStateMetrics:
      enabled: true
      url: ""
      timeoutSeconds: 10
    kubeletSummary:
      enabled: true
addons:
  kubeStateMetrics:
    enabled: true
  metricsServer:
    enabled: false
```

- `backend.url`: public SaaS API URL.
- `auth.email`: dashboard user email for tenant lookup.
- `auth.accessKey`: one-time agent key generated in dashboard.
- `cluster.name`: display name and unique cluster name within the organization.
- `agent.image.repository`: collector image registry/repository.
- `agent.metrics.enabled`: enables metrics collection loops inside the collector.
- `agent.metrics.intervalSeconds`: frequency for metrics collection.
- `agent.metrics.resourceUsage.enabled`: polls `metrics.k8s.io` for live pod/node CPU-memory usage.
- `agent.metrics.kubeStateMetrics.enabled`: scrapes `kube-state-metrics` for requests, limits, replica counts, and pod phase signals.
- `agent.metrics.kubeletSummary.enabled`: samples node/pod summary metrics through the Kubernetes API proxy for network and filesystem panels.
- `addons.kubeStateMetrics.enabled`: installs `kube-state-metrics` with the agent release.
- `addons.metricsServer.enabled`: installs a release-scoped Metrics Server only when the customer cluster does not already provide one.

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
  --version 0.1.3 \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

To correct an existing install with a bad image registry:

```bash
helm upgrade clusterwatch-agent oci://acrclustersage.azurecr.io/helm/clusterwatch-agent \
  --version 0.1.3 \
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
kubectl get deployment clusterwatch-kube-state-metrics -n clusterwatch-agent
kubectl top pods -A
nslookup acrclustersage.azurecr.io
```

## Uninstall

```bash
helm uninstall clusterwatch-agent -n clusterwatch-agent
kubectl delete namespace clusterwatch-agent
```
