# Environment Variables

## Backend

| Variable | Required | Secret | Example | Azure source |
|---|---:|---:|---|---|
| `APP_ENV` | yes | no | `production` | deployment environment |
| `APP_NAME` | no | no | `ClusterSage` | app display name |
| `PUBLIC_APP_URL` | yes | no | `https://nexaflow.site` | DNS name |
| `PUBLIC_API_URL` | yes | no | `https://nexaflow.site` | DNS name |
| `DATABASE_URL` | yes | yes | `postgresql+asyncpg://user:pass@server.postgres.database.azure.com:5432/clusterwatch?ssl=require` | PostgreSQL Flexible Server |
| `JWT_SECRET` | yes | yes | output of `openssl rand -hex 32` | generated locally/Key Vault |
| `JWT_ALGORITHM` | yes | no | `HS256` | fixed unless rotating algorithms |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | yes | no | `1440` | policy |
| `AGENT_TOKEN_SECRET` | yes | yes | output of `openssl rand -hex 32` | generated locally/Key Vault |
| `AGENT_TOKEN_EXPIRE_HOURS` | yes | no | `720` | policy |
| `AZURE_STORAGE_CONNECTION_STRING` | yes | yes | `DefaultEndpointsProtocol=https;...` | `az storage account show-connection-string` |
| `AZURE_STORAGE_CONTAINER` | yes | no | `clusterwatch-data` | fixed private container |
| `AZURE_SERVICEBUS_CONNECTION_STRING` | production fallback | yes | empty | fallback Service Bus auth |
| `AZURE_SERVICEBUS_FULLY_QUALIFIED_NAMESPACE` | production | no | empty | Managed Identity Service Bus auth |
| `CLUSTER_CONNECTED_QUEUE_NAME` | production | no | `cluster-connected` | cluster connection notification queue |
| `AZURE_COMMUNICATION_EMAIL_CONNECTION_STRING` | production fallback | yes | empty | fallback email auth |
| `AZURE_COMMUNICATION_EMAIL_ENDPOINT` | production | no | empty | Managed Identity email endpoint |
| `EMAIL_SENDER_ADDRESS` | production | no | empty | verified ACS sender address |
| `LOG_BATCH_MAX_SIZE_MB` | yes | no | `10` | ingestion policy |
| `LOG_RETENTION_DAYS` | no | no | `30` | lifecycle policy input |
| `CORS_ALLOWED_ORIGINS` | yes | no | `https://nexaflow.site` | frontend URL |
| `AI_PROVIDER` | no | no | `disabled` | future AI setting |
| `AZURE_OPENAI_ENDPOINT` | no | no | `https://acct.openai.azure.com` | future Azure OpenAI resource |
| `AZURE_OPENAI_API_KEY` | optional | yes | `<key>` | optional Key Vault secret when API key fallback is enabled |
| `AZURE_OPENAI_DEPLOYMENT` | no | no | `gpt-4.1-mini` | future deployment name |
| `AZURE_AI_FOUNDRY_ENDPOINT` | AI phase | no | `https://<openai-account>.openai.azure.com/` | prod Terraform `ai_foundry_endpoint` output |
| `AZURE_AI_FOUNDRY_PROJECT_NAME` | optional | no | `clustersage-prod` | reserved for future project-level integration |
| `AZURE_AI_FOUNDRY_PROJECT_ID` | optional | no | `<project-id>` | reserved for future project-level integration |
| `AZURE_AI_FOUNDRY_DEPLOYMENT_NAME` | AI phase | no | `gpt-4.1-mini` | prod Terraform `ai_foundry_deployment_name` output |
| `AZURE_AI_FOUNDRY_API_VERSION` | AI phase | no | `2024-05-01-preview` | Azure AI Foundry API version |
| `AZURE_CLIENT_ID` | hosted backend | no | `<managed-identity-client-id>` | workload identity / managed identity, typically the same client ID used in the service account annotation |
| `AI_ANALYSIS_ENABLED` | AI phase | no | `false` | feature flag |
| `AI_CLUSTER_QUERY_ENABLED` | AI phase | no | `false` | feature flag |
| `REMEDIATION_APPROVAL_ENABLED` | remediation phase | no | `true` | feature flag |
| `AGENT_REMEDIATION_ENABLED` | remediation phase | no | `false` | feature flag |
| `AI_MAX_LOG_LINES_PER_ANALYSIS` | AI phase | no | `200` | prompt guardrail |
| `AI_MAX_TOKENS` | AI phase | no | `1200` | prompt guardrail |
| `AI_TEMPERATURE` | AI phase | no | `0` | deterministic AI setting |
| `AI_PROMPT_VERSION` | AI phase | no | `v1` | prompt version tracking |

## Frontend

| Variable | Required | Secret | Example |
|---|---:|---:|---|
| `NEXT_PUBLIC_API_URL` | yes | no | `https://nexaflow.site` |
| `NEXT_PUBLIC_APP_NAME` | no | no | `ClusterSage` |

## Agent

| Variable | Required | Secret | Example |
|---|---:|---:|---|
| `CLUSTERWATCH_BACKEND_URL` | yes | no | `https://nexaflow.site` |
| `CLUSTERWATCH_EMAIL` | yes | no | `owner@example.com` |
| `CLUSTERWATCH_ACCESS_KEY` | yes | yes | `cw_live_...` |
| `CLUSTERWATCH_CLUSTER_NAME` | yes | no | `prod-aks-01` |
| `CLUSTERWATCH_CLUSTER_PROVIDER` | yes | no | `aks` |
| `CLUSTERWATCH_AGENT_VERSION` | yes | no | `0.1.0` |
| `CLUSTERWATCH_HEARTBEAT_INTERVAL_SECONDS` | yes | no | `30` |
| `CLUSTERWATCH_SNAPSHOT_INTERVAL_SECONDS` | yes | no | `60` |
| `CLUSTERWATCH_REMEDIATION_ENABLED` | remediation phase | no | `false` |
| `CLUSTERWATCH_REMEDIATION_CLUSTER_WIDE` | remediation phase | no | `false` |
| `CLUSTERWATCH_REMEDIATION_ALLOWED_NAMESPACES` | remediation phase | no | `prod,platform` |
| `CLUSTERWATCH_REMEDIATION_ALLOWED_ACTIONS` | remediation phase | no | `rollout_restart` |
| `CLUSTERWATCH_REMEDIATION_POLL_INTERVAL_SECONDS` | remediation phase | no | `30` |
| `CLUSTERWATCH_LOG_LEVEL` | yes | no | `info` |
