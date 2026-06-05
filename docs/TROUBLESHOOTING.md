# Troubleshooting

## Backend Health

```bash
curl http://localhost:8000/health
docker compose logs -f backend
kubectl logs deploy/clusterwatch-backend -n clusterwatch
```

If migrations are missing:

```bash
docker compose exec backend alembic upgrade head
kubectl exec deploy/clusterwatch-backend -n clusterwatch -- alembic upgrade head
```

## PostgreSQL

```bash
docker compose exec postgres psql -U clusterwatch -d clusterwatch -c "select now();"
az postgres flexible-server connect -g <rg> -n <server> --admin-user <user> --database-name clusterwatch
```

## Blob Storage

```bash
az storage container show --account-name <storage-account> --name clusterwatch-data --auth-mode login
az storage blob list --account-name <storage-account> --container-name clusterwatch-data --auth-mode login --output table
```

## Agent Registration

```bash
kubectl logs deploy/clusterwatch-collector -n clusterwatch-agent
kubectl get secret clusterwatch-agent-auth -n clusterwatch-agent -o yaml
```

A 401 means the email/key pair is wrong, the key was revoked, or the key expired.

## RBAC

```bash
kubectl auth can-i list pods --as system:serviceaccount:clusterwatch-agent:clusterwatch-agent --all-namespaces
kubectl auth can-i list secrets --as system:serviceaccount:clusterwatch-agent:clusterwatch-agent --all-namespaces
```

The first command should return `yes`; the second should return `no`.
