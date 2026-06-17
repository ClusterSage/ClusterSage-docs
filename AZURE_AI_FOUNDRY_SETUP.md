# Azure AI Foundry Setup

ClusterSage prod now has a dedicated Terraform module for Azure OpenAI / Azure AI Foundry-style model hosting in:

- `repos/ClusterSage-infra/terraform/modules/ai-foundry`
- `repos/ClusterSage-infra/terraform/envs/prod`

## What Terraform Provisions

When `ai_foundry_enabled = true` in the prod root:

1. An Azure Cognitive Services OpenAI account
2. A model deployment inside that account
3. An RBAC assignment for the backend workload managed identity
4. Optionally, an API key copied into the prod Key Vault

The current backend runtime only requires:

- `AZURE_AI_FOUNDRY_ENDPOINT`
- `AZURE_AI_FOUNDRY_DEPLOYMENT_NAME`
- `AZURE_AI_FOUNDRY_API_VERSION`

It can authenticate in two ways:

1. Preferred: workload identity / managed identity
2. Optional fallback: `AZURE_OPENAI_API_KEY` from Key Vault

## Recommended Production Mode

Use workload identity first.

That means:

- keep `ai_store_api_key_in_key_vault = false`
- keep the backend service account annotated with the workload identity client ID
- set backend env `AZURE_CLIENT_ID` to the same user-assigned identity client ID

## Optional API Key Fallback

If you need API key auth for the backend:

- set `ai_store_api_key_in_key_vault = true`
- Terraform will store the account primary key as a Key Vault secret
- add the same secret name to the platform chart `keyVault.objects`
- mount/export it as `AZURE_OPENAI_API_KEY`

Do not enable the Key Vault secret mount until the secret really exists, or the CSI mount can fail.

## Current Limitation

The current Terraform implementation provisions the OpenAI account and deployment that ClusterSage actually consumes today.

It does not yet provision an Azure AI Foundry project resource because:

- the current backend client does not require it
- the required account/deployment path is already supported by `azurerm`
- this keeps the prod plan smaller and lower-risk for now

If ClusterSage later needs project-level objects, add them behind an explicit follow-up phase and validate provider support first.
