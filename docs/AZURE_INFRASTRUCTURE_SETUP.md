# KubeSage Azure Infrastructure Setup

The Terraform stack in `terraform/` provisions the Azure foundation for KubeSage:

- Resource group
- Virtual network and AKS subnet
- AKS with OIDC issuer and Workload Identity enabled
- Azure Container Registry
- Azure Front Door Premium
- Azure Front Door WAF policy with managed rules
- Service Bus namespace and `cluster-connected` queue
- Key Vault with RBAC authorization
- User-assigned Managed Identity
- PostgreSQL Flexible Server
- Storage Account and private Blob container
- Log Analytics Workspace
- Application Insights

## Prerequisites

- Azure CLI logged in with `az login`
- Terraform 1.6 or newer
- Permission to create resource groups, AKS, ACR, Front Door, Service Bus, Key Vault, PostgreSQL, role assignments, and monitoring resources
- A GoDaddy-managed domain: `nexaflow.site`

## Terraform Layout

```text
terraform/
  main.tf
  variables.tf
  outputs.tf
  providers.tf
  locals.tf
  terraform.tfvars.example
  modules/
    resource-group/
    networking/
    frontdoor/
    waf/
    service-bus/
    storage/
    key-vault/
    managed-identity/
    app-hosting/
    database/
    monitoring/
```

## Terraform Commands

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

Set `origin_host_name` and `origin_host_header` to the hostname that fronts the deployed Kubernetes ingress or external load balancer. If you do not know it yet, deploy AKS first, deploy the Helm chart, get the ingress/load balancer hostname, update `terraform.tfvars`, and run `terraform plan` again.

## Application Deployment

1. Build and push images to the Terraform-created ACR.
2. Get AKS credentials:

```bash
az aks get-credentials -g <resource-group> -n <aks-name>
```

3. Deploy the platform chart:

```bash
helm upgrade --install clusterwatch-platform ./deploy/helm/clusterwatch-platform \
  --namespace clusterwatch \
  --create-namespace \
  -f platform-values.yaml
```

4. Include the email worker values and Service Bus/email settings in `platform-values.yaml`.

## GoDaddy DNS For nexaflow.site

After Terraform creates the Front Door custom domain, capture:

- Front Door endpoint hostname from Terraform output `frontdoor_endpoint_hostname`
- Validation token from Terraform output `frontdoor_custom_domain_validation_token`

In GoDaddy DNS for `nexaflow.site`, create:

- `CNAME` record:
  - Name: `@` if GoDaddy supports apex CNAME/flattening, otherwise use `www`
  - Value: the Front Door endpoint hostname, for example `fde-kubesage-prod.azurefd.net`
- `TXT` record for Azure domain validation:
  - Name: `_dnsauth` for apex validation, or `_dnsauth.www` for `www.nexaflow.site`
  - Value: `frontdoor_custom_domain_validation_token`

If GoDaddy does not support apex CNAME flattening for `nexaflow.site`, use `www.nexaflow.site` in Front Door and redirect the apex domain from GoDaddy to `https://www.nexaflow.site`.

After DNS propagates:

1. Open the Azure Front Door custom domain in Azure.
2. Validate the domain.
3. Enable HTTPS with Azure-managed certificate.
4. Verify:

```bash
curl -I https://nexaflow.site/health
```

Traffic flow:

```text
User -> nexaflow.site DNS -> Azure Front Door + WAF -> AKS ingress/load balancer -> frontend/API services
```

## Service Bus And Email

The API needs sender access to Service Bus. The email worker needs receiver access and access to Azure Communication Services Email. Prefer Managed Identity with these settings:

- `AZURE_SERVICEBUS_FULLY_QUALIFIED_NAMESPACE`
- `CLUSTER_CONNECTED_QUEUE_NAME=cluster-connected`
- `AZURE_COMMUNICATION_EMAIL_ENDPOINT`
- `EMAIL_SENDER_ADDRESS`

Connection string variables exist only as fallbacks for local development or constrained environments.

## Verification

```bash
az account show
az group show -n <resource-group>
az servicebus namespace list -g <resource-group>
az keyvault list -g <resource-group>
az aks show -g <resource-group> -n <aks-name>
az acr show -g <resource-group> -n <acr-name>
az network front-door waf-policy list -g <resource-group>
```

## Manual Steps Still Required

- GoDaddy CNAME/TXT records
- Azure Communication Services email domain verification
- Helm values containing runtime URLs, image tags, and secrets/Key Vault references
- Front Door origin hostname update after ingress/load balancer creation
- Store generated storage/database/email secrets in Key Vault or pass them into Helm as secret values
