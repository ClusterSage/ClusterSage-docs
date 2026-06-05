# Azure VM Deployment

Use this for a simple production deployment where Docker Compose runs on one Ubuntu VM and managed Azure PostgreSQL/Storage hold state.

## Azure Setup

```bash
export SUBSCRIPTION_ID="<subscription-id>"
export LOCATION="eastus"
export RESOURCE_GROUP="rg-clusterwatch-prod"
export ACR_NAME="acrclusterwatchprod"
export POSTGRES_SERVER="pg-clusterwatch-prod"
export POSTGRES_ADMIN="clusterwatchadmin"
export POSTGRES_PASSWORD="<strong-password>"
export POSTGRES_DB="clusterwatch"
export STORAGE_ACCOUNT="stclusterwatchprod"
export VM_NAME="vm-clusterwatch-prod"
export VM_ADMIN="azureuser"
az login
az account set --subscription "$SUBSCRIPTION_ID"
az group create -n "$RESOURCE_GROUP" -l "$LOCATION"
```

## ACR and Images

```bash
az acr create -g "$RESOURCE_GROUP" -n "$ACR_NAME" --sku Basic --admin-enabled true
az acr login -n "$ACR_NAME"
docker build -t "$ACR_NAME.azurecr.io/clusterwatch-backend:0.1.0" apps/backend
docker build -t "$ACR_NAME.azurecr.io/clusterwatch-frontend:0.1.0" apps/frontend
docker build -t "$ACR_NAME.azurecr.io/clusterwatch-agent:0.1.0" agent/collector
docker push "$ACR_NAME.azurecr.io/clusterwatch-backend:0.1.0"
docker push "$ACR_NAME.azurecr.io/clusterwatch-frontend:0.1.0"
docker push "$ACR_NAME.azurecr.io/clusterwatch-agent:0.1.0"
```

## PostgreSQL and Storage

```bash
az postgres flexible-server create -g "$RESOURCE_GROUP" -n "$POSTGRES_SERVER" -l "$LOCATION" \
  --admin-user "$POSTGRES_ADMIN" --admin-password "$POSTGRES_PASSWORD" \
  --sku-name Standard_B1ms --tier Burstable --storage-size 32 --version 16 --public-access 0.0.0.0
az postgres flexible-server db create -g "$RESOURCE_GROUP" --server-name "$POSTGRES_SERVER" --database-name "$POSTGRES_DB"
az storage account create -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" -l "$LOCATION" --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2
az storage container create --account-name "$STORAGE_ACCOUNT" --name clusterwatch-data --auth-mode login --public-access off
az storage account show-connection-string -g "$RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --query connectionString -o tsv
```

## VM and Ports

```bash
az vm create -g "$RESOURCE_GROUP" -n "$VM_NAME" --image Ubuntu2204 --admin-username "$VM_ADMIN" --generate-ssh-keys --size Standard_B2s
az vm open-port -g "$RESOURCE_GROUP" -n "$VM_NAME" --port 80
az vm open-port -g "$RESOURCE_GROUP" -n "$VM_NAME" --port 443
az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" -d --query publicIps -o tsv
```

## Deploy Compose

SSH to the VM, install Docker, copy `infra/docker-compose.prod.yml` as `docker-compose.yml`, and create `.env`.

```bash
ssh azureuser@<vm-public-ip>
bash deploy/vm/install-docker.sh
mkdir -p /opt/clusterwatch
cd /opt/clusterwatch
```

Create `/opt/clusterwatch/.env` with backend secrets and image names. Then run:

```bash
docker compose up -d
docker compose exec backend alembic upgrade head
curl http://localhost:8000/health
```

## Nginx and HTTPS

```bash
sudo cp deploy/nginx/clusterwatch.conf.example /etc/nginx/sites-available/clusterwatch
sudo ln -s /etc/nginx/sites-available/clusterwatch /etc/nginx/sites-enabled/clusterwatch
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d app.example.com -d api.example.com
```

## Cleanup

```bash
az group delete -n "$RESOURCE_GROUP" --yes --no-wait
```
