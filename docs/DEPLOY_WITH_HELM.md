# Deploy With Helm

## SaaS Platform

Create `platform-values.yaml`:

```yaml
frontend:
  image:
    repository: acrclusterwatchprod.azurecr.io/clusterwatch-frontend
    tag: "0.1.0"
  env:
    NEXT_PUBLIC_API_URL: "https://api.example.com"
backend:
  image:
    repository: acrclusterwatchprod.azurecr.io/clusterwatch-backend
    tag: "0.1.0"
  env:
    APP_ENV: "production"
    PUBLIC_APP_URL: "https://app.example.com"
    PUBLIC_API_URL: "https://api.example.com"
    CORS_ALLOWED_ORIGINS: "https://app.example.com"
    AZURE_STORAGE_CONTAINER: "clusterwatch-data"
  secrets:
    DATABASE_URL: "postgresql+asyncpg://clusterwatch:<password>@pg.example.postgres.database.azure.com:5432/clusterwatch?ssl=require"
    JWT_SECRET: "<openssl-rand-hex-32>"
    AGENT_TOKEN_SECRET: "<openssl-rand-hex-32>"
    AZURE_STORAGE_CONNECTION_STRING: "<storage-connection-string>"
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths: [{ path: /, pathType: Prefix, service: frontend }]
    - host: api.example.com
      paths: [{ path: /, pathType: Prefix, service: backend }]
```

Install:

```bash
helm upgrade --install clusterwatch-platform ./deploy/helm/clusterwatch-platform \
  --namespace clusterwatch \
  --create-namespace \
  -f platform-values.yaml
```

## Customer Agent

```bash
helm upgrade --install clusterwatch-agent ./agent/helm/clusterwatch-agent \
  --namespace clusterwatch-agent \
  --create-namespace \
  -f clusterwatch-values.yaml
```

Uninstall:

```bash
helm uninstall clusterwatch-agent -n clusterwatch-agent
kubectl delete namespace clusterwatch-agent
```
