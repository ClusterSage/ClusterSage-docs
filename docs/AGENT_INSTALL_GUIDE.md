# Agent Install Guide

The customer-installed agent runs inside the customer cluster and only connects outbound to the ClusterSage backend.

## Required Values

```yaml
backend:
  url: "https://www.nexaflow.site"
auth:
  email: "owner@example.com"
  accessKey: "cw_live_copy_from_dashboard"
cluster:
  name: "prod-aks-01"
  provider: "aks"
agent:
  image:
    repository: "acrkubesageprod.azurecr.io/clustersage-agent"
    tag: "stable"
```

- `backend.url`: public SaaS API URL.
- `auth.email`: dashboard user email for tenant lookup.
- `auth.accessKey`: one-time agent key generated in dashboard.
- `cluster.name`: display name and unique cluster name within the organization.
- `agent.image.repository`: collector image registry/repository.

The image registry must be a real, resolvable ACR login server. If Kubernetes shows `lookup <registry>.azurecr.io ... no such host`, the registry hostname in the values file is wrong or the customer cluster cannot resolve public DNS.

## Public Agent Image Pull

The ClusterSage agent image is published with anonymous pull enabled. Customer clusters do not need Docker login or Kubernetes image pull secrets for the default image.

```bash
docker pull acrkubesageprod.azurecr.io/clustersage-agent:stable
crictl pull acrkubesageprod.azurecr.io/clustersage-agent:stable
```

Use `stable` for normal installs. The image publishing workflow also pushes immutable version and commit tags for rollback/debugging.

## Install

```bash
helm upgrade --install clusterwatch-agent ./agent/helm/clusterwatch-agent \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

For customer installs, use the published OCI Helm chart:

```bash
helm upgrade --install clusterwatch-agent oci://acrkubesageprod.azurecr.io/helm/clusterwatch-agent \
  --version 0.1.0 \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

To correct an existing install with a bad image registry:

```bash
helm upgrade clusterwatch-agent oci://acrkubesageprod.azurecr.io/helm/clusterwatch-agent \
  --version 0.1.0 \
  --namespace clusterwatch-agent \
  --reuse-values \
  --set agent.image.repository="acrkubesageprod.azurecr.io/clustersage-agent" \
  --set agent.image.tag="stable"
```

## Verify

```bash
kubectl get pods -n clusterwatch-agent
kubectl logs deploy/clusterwatch-collector -n clusterwatch-agent
kubectl get daemonset clusterwatch-fluent-bit -n clusterwatch-agent
curl https://www.nexaflow.site/health
```

## Troubleshoot

```bash
kubectl describe pod -n clusterwatch-agent -l app.kubernetes.io/component=collector
kubectl logs -n clusterwatch-agent -l app.kubernetes.io/component=fluent-bit
kubectl auth can-i list pods --as system:serviceaccount:clusterwatch-agent:clusterwatch-agent --all-namespaces
nslookup acrkubesageprod.azurecr.io
```

## Uninstall

```bash
helm uninstall clusterwatch-agent -n clusterwatch-agent
kubectl delete namespace clusterwatch-agent
```
