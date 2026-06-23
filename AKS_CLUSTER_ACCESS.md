# AKS Cluster Access

These `ClusterRoleBinding` manifests grant full cluster access by binding Microsoft Entra ID groups to the built-in `cluster-admin` `ClusterRole`.

Current group object IDs:

- Admin: `11724d97-58ae-4c41-95d5-51a415ca9db5`
- Dev: `913bfe0a-6c1e-49a5-8ec8-f10a9304e38a`

Access scope:

- `aks-clustersage-prod`: admin only
- `aks-clustersage-dev`: admin and dev

## Prod

Apply this against the `aks-clustersage-prod` cluster.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entra-admin-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: "11724d97-58ae-4c41-95d5-51a415ca9db5"
```

## Dev

Apply these against the `aks-clustersage-dev` cluster.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entra-admin-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: "11724d97-58ae-4c41-95d5-51a415ca9db5"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entra-dev-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: "913bfe0a-6c1e-49a5-8ec8-f10a9304e38a"
```

## Apply

Example flow:

```bash
kubectl config use-context aks-clustersage-prod
kubectl apply -f k8s/aks-clustersage-prod-clusterrolebinding.yaml

kubectl config use-context aks-clustersage-dev
kubectl apply -f k8s/aks-clustersage-dev-clusterrolebindings.yaml
```

If your kubeconfig context names differ, switch to the matching local context before applying.
