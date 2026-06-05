# Helm Charts

## Customer Agent Chart

Path: `agent/helm/clusterwatch-agent`.

Required values:

- `backend.url`
- `auth.email`
- `auth.accessKey`
- `cluster.name`
- `agent.image.repository`

The chart installs a Namespace, ServiceAccount, read-only ClusterRole/ClusterRoleBinding, Secret, collector Service/Deployment, Fluent Bit ConfigMap, and Fluent Bit DaemonSet.

Validate values:

```bash
helm lint ./agent/helm/clusterwatch-agent -f clusterwatch-values.yaml
helm template clusterwatch-agent ./agent/helm/clusterwatch-agent -n clusterwatch-agent -f clusterwatch-values.yaml
```

## Platform Chart

Path: `deploy/helm/clusterwatch-platform`.

The chart installs frontend and backend Deployments, Services, Ingress, ConfigMap, Secret, Namespace, and optional migration Job.

Validate:

```bash
helm lint ./deploy/helm/clusterwatch-platform -f platform-values.yaml
helm template clusterwatch-platform ./deploy/helm/clusterwatch-platform -n clusterwatch -f platform-values.yaml
```
