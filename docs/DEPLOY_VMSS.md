# Azure VMSS Deployment

Use VMSS when you want multiple identical VM instances running Docker Compose. Keep PostgreSQL and Blob Storage managed outside the scale set.

## Prerequisites

Complete the ACR, PostgreSQL, and Storage steps from `docs/DEPLOY_VM.md`.

## Create VMSS

```bash
export RESOURCE_GROUP="rg-clusterwatch-prod"
export LOCATION="eastus"
export VMSS_NAME="vmss-clusterwatch-prod"
export VM_ADMIN="azureuser"
az vmss create -g "$RESOURCE_GROUP" -n "$VMSS_NAME" --image Ubuntu2204 \
  --admin-username "$VM_ADMIN" --generate-ssh-keys --instance-count 2 \
  --upgrade-policy-mode automatic --load-balancer clusterwatch-lb
az network lb rule create -g "$RESOURCE_GROUP" --lb-name clusterwatch-lb -n http \
  --protocol Tcp --frontend-port 80 --backend-port 80
az network lb rule create -g "$RESOURCE_GROUP" --lb-name clusterwatch-lb -n https \
  --protocol Tcp --frontend-port 443 --backend-port 443
```

## Custom Script Extension

Upload `deploy/vmss/custom-script.sh` to a private storage container or a repo URL accessible by the VMSS. Update `deploy/vmss/custom-script-settings.json`, then run:

```bash
az vmss extension set -g "$RESOURCE_GROUP" --vmss-name "$VMSS_NAME" \
  --name CustomScript --publisher Microsoft.Azure.Extensions \
  --settings deploy/vmss/custom-script-settings.json
az vmss update-instances -g "$RESOURCE_GROUP" -n "$VMSS_NAME" --instance-ids "*"
```

## Verify

```bash
az vmss list-instances -g "$RESOURCE_GROUP" -n "$VMSS_NAME" -o table
az network lb show -g "$RESOURCE_GROUP" -n clusterwatch-lb --query frontendIpConfigurations -o table
```

## Cleanup

```bash
az vmss delete -g "$RESOURCE_GROUP" -n "$VMSS_NAME"
```
