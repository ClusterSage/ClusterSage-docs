# Terraform Prod AI Foundry

## Files

- Module: `repos/ClusterSage-infra/terraform/modules/ai-foundry`
- Prod root: `repos/ClusterSage-infra/terraform/envs/prod`

## Prod Variables

The prod root now supports:

- `ai_foundry_enabled`
- `ai_foundry_name`
- `ai_foundry_location`
- `ai_model_deployment_name`
- `ai_model_name`
- `ai_model_version`
- `ai_model_sku_name`
- `ai_model_capacity`
- `ai_foundry_api_version`
- `ai_prompt_version`
- `ai_store_api_key_in_key_vault`
- `ai_key_vault_secret_name`
- `ai_local_auth_enabled`
- `ai_public_network_access_enabled`

See:

- `repos/ClusterSage-infra/terraform/envs/prod/variables.tf`
- `repos/ClusterSage-infra/terraform/envs/prod/terraform.tfvars.example`

## Outputs

The prod root now exposes:

- `ai_foundry_endpoint`
- `ai_foundry_name`
- `ai_foundry_deployment_name`
- `ai_foundry_api_version`
- `ai_key_vault_secret_name`
- `ai_foundry_primary_access_key` (sensitive, only when API key storage is enabled)

## Backend Runtime Mapping

These Terraform outputs map to backend runtime values:

- `ai_foundry_endpoint` -> `AZURE_AI_FOUNDRY_ENDPOINT`
- `ai_foundry_deployment_name` -> `AZURE_AI_FOUNDRY_DEPLOYMENT_NAME`
- `ai_foundry_api_version` -> `AZURE_AI_FOUNDRY_API_VERSION`
- managed identity client ID -> `AZURE_CLIENT_ID`

Feature flags in the platform chart:

- `AI_ANALYSIS_ENABLED`
- `AI_CLUSTER_QUERY_ENABLED`
- `REMEDIATION_APPROVAL_ENABLED`
- `AGENT_REMEDIATION_ENABLED`

## Validation Commands

Run from `repos/ClusterSage-infra/terraform/envs/prod`:

```powershell
terraform init -backend=false
terraform fmt
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

If `terraform plan` fails because Azure authentication is missing locally, that is an operator environment issue rather than a syntax issue in the module itself.

## Safe Rollout Order

1. Merge the Terraform and chart changes.
2. Review prod `terraform.tfvars`.
3. Run `terraform plan` for prod.
4. Apply only after reviewing the OpenAI account and deployment resources.
5. Copy the resulting endpoint and deployment name into the prod GitOps values if you are not templating them from another system.
6. Sync ArgoCD after the runtime values and identity wiring are correct.
