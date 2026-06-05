# AKS Deployment

Use AKS for the production SaaS platform when you want Kubernetes-native scaling, ingress, and Helm releases.

## Azure Resources

```bash
export SUBSCRIPTION_ID="<subscription-id>"
export LOCATION="eastus"
export RESOURCE_GROUP="rg-clusterwatch-prod"
export ACR_NAME="acrclusterwatchprod"
export AKS_NAME="aks-clusterwatch-prod"
az login
az account set --subscription "$SUBSCRIPTION_ID"
az group create -n "$RESOURCE_GROUP" -l "$LOCATION"
az acr create -g "$RESOURCE_GROUP" -n "$ACR_NAME" --sku Basic
az aks create -g "$RESOURCE_GROUP" -n "$AKS_NAME" --node-count 2 --node-vm-size Standard_B2s --attach-acr "$ACR_NAME" --generate-ssh-keys
az aks get-credentials -g "$RESOURCE_GROUP" -n "$AKS_NAME"
```

## Build and Push

```bash
az acr login -n "$ACR_NAME"
docker build -t "$ACR_NAME.azurecr.io/clusterwatch-backend:0.1.0" apps/backend
docker build -t "$ACR_NAME.azurecr.io/clusterwatch-frontend:0.1.0" apps/frontend
docker build -t "$ACR_NAME.azurecr.io/clusterwatch-agent:0.1.0" agent/collector
docker push "$ACR_NAME.azurecr.io/clusterwatch-backend:0.1.0"
docker push "$ACR_NAME.azurecr.io/clusterwatch-frontend:0.1.0"
docker push "$ACR_NAME.azurecr.io/clusterwatch-agent:0.1.0"
```

## Nginx Ingress

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
kubectl get svc -n ingress-nginx
```

Point DNS records for `app.example.com` and `api.example.com` to the ingress external IP.

## Deploy with Raw Manifests

Edit `deploy/k8s/secrets.example.yaml` and image names, then:

```bash
kubectl apply -f deploy/k8s/namespace.yaml
kubectl apply -f deploy/k8s/secrets.example.yaml
kubectl apply -f deploy/k8s/backend-deployment.yaml
kubectl apply -f deploy/k8s/frontend-deployment.yaml
kubectl apply -f deploy/k8s/services.yaml
kubectl apply -f deploy/k8s/ingress.yaml
kubectl exec deploy/clusterwatch-backend -n clusterwatch -- alembic upgrade head
```

## Verify

```bash
kubectl get pods -n clusterwatch
kubectl logs deploy/clusterwatch-backend -n clusterwatch
curl https://api.example.com/health
```
