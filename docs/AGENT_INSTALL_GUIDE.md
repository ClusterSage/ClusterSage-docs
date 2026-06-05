# Agent Install Guide

The customer-installed agent runs inside the customer cluster and only connects outbound to the ClusterWatch backend.

## Required Values

```yaml
backend:
  url: "https://api.example.com"
auth:
  email: "owner@example.com"
  accessKey: "cw_live_copy_from_dashboard"
cluster:
  name: "prod-aks-01"
  provider: "aks"
agent:
  image:
    repository: "acrclusterwatchprod.azurecr.io/clusterwatch-agent"
    tag: "0.1.0"
```

- `backend.url`: public SaaS API URL.
- `auth.email`: dashboard user email for tenant lookup.
- `auth.accessKey`: one-time agent key generated in dashboard.
- `cluster.name`: display name and unique cluster name within the organization.
- `agent.image.repository`: collector image registry/repository.

## Install

```bash
helm upgrade --install clusterwatch-agent ./agent/helm/clusterwatch-agent \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

## Verify

```bash
kubectl get pods -n clusterwatch-agent
kubectl logs deploy/clusterwatch-collector -n clusterwatch-agent
kubectl get daemonset clusterwatch-fluent-bit -n clusterwatch-agent
curl https://api.example.com/health
```

## Troubleshoot

```bash
kubectl describe pod -n clusterwatch-agent -l app.kubernetes.io/component=collector
kubectl logs -n clusterwatch-agent -l app.kubernetes.io/component=fluent-bit
kubectl auth can-i list pods --as system:serviceaccount:clusterwatch-agent:clusterwatch-agent --all-namespaces
```

## Uninstall

```bash
helm uninstall clusterwatch-agent -n clusterwatch-agent
kubectl delete namespace clusterwatch-agent
```
