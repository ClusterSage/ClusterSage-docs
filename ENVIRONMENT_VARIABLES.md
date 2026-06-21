# Environment Variables

## Environment URL Contract

| Environment | Public app/API host | Frontend API host | Agent backend host |
|---|---|---|---|
| `dev` | `https://dev.nexaflow.site` | `https://dev.nexaflow.site` | `https://dev.nexaflow.site` |
| `staging` | `https://stage.nexaflow.site` | `https://stage.nexaflow.site` | `https://stage.nexaflow.site` |
| `prod` | `https://nexaflow.site` | `https://nexaflow.site` | `https://nexaflow.site` |

These values are environment-specific. The examples below use production values unless a row explicitly says otherwise.

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
| `AI_AGENT_ENABLED` | AI agent phase | no | `false` | enables the conversation-based cluster investigation assistant |
| `ALERT_EVALUATION_ENABLED` | alerting phase | no | `false` | enables backend alert evaluation loop |
| `ALERT_EVALUATION_INTERVAL_SECONDS` | alerting phase | no | `60` | background alert evaluation interval |
| `REMEDIATION_APPROVAL_ENABLED` | remediation phase | no | `true` | feature flag |
| `AGENT_REMEDIATION_ENABLED` | remediation phase | no | `false` | feature flag |
| `AI_MAX_LOG_LINES_PER_ANALYSIS` | AI phase | no | `200` | prompt guardrail |
| `AI_MAX_TOKENS` | AI phase | no | `1200` | prompt guardrail |
| `AI_TEMPERATURE` | AI phase | no | `0` | deterministic AI setting |
| `AI_PROMPT_VERSION` | AI phase | no | `v1` | prompt version tracking |
| `AI_AGENT_MAX_TOOL_CALLS` | AI agent phase | no | `6` | maximum server-executed tool calls per chat request |
| `AI_AGENT_MAX_ITERATIONS` | AI agent phase | no | `4` | maximum model/tool loop iterations per request |
| `AI_AGENT_MAX_CONTEXT_TOKENS` | AI agent phase | no | `12000` | bounded conversation context budget |
| `AI_AGENT_MAX_HISTORY_MESSAGES` | AI agent phase | no | `8` | recent conversation messages sent to the model |
| `AI_AGENT_TOOL_TIMEOUT_SECONDS` | AI agent phase | no | `8` | per-tool timeout |
| `AI_AGENT_REQUEST_TIMEOUT_SECONDS` | AI agent phase | no | `45` | overall model request timeout |
| `AI_AGENT_MAX_DB_ROWS` | AI agent phase | no | `50` | maximum rows returned by a database-backed tool |
| `AI_AGENT_MAX_LOG_MATCHES` | AI agent phase | no | `20` | bounded returned log matches |
| `AI_AGENT_MAX_BLOB_BYTES` | AI agent phase | no | `1048576` | maximum bytes read from an approved document blob |
| `AI_AGENT_MAX_BLOB_BATCHES` | AI agent phase | no | `8` | maximum log/blob batches scanned in one request |
| `AI_AGENT_MAX_DOCUMENT_CHARACTERS` | AI agent phase | no | `4000` | maximum excerpt size returned from one document |
| `AI_AGENT_KNOWLEDGE_BASE_MAX_RESULTS` | AI agent phase | no | `5` | maximum curated knowledge-base sections returned |
| `AI_AGENT_LOG_MAX_TIME_RANGE_HOURS` | AI agent phase | no | `24` | maximum log search lookback window |
| `AI_AGENT_PROMPT_VERSION` | AI agent phase | no | `cluster-investigator-v1` | prompt/version tag for conversation responses |

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
| `CLUSTERWATCH_POD_NAMESPACE` | chart-set | no | `clusterwatch-agent` |
| `CLUSTERWATCH_HEARTBEAT_INTERVAL_SECONDS` | yes | no | `30` |
| `CLUSTERWATCH_SNAPSHOT_INTERVAL_SECONDS` | yes | no | `60` |
| `CLUSTERWATCH_METRICS_ENABLED` | telemetry phase | no | `true` |
| `CLUSTERWATCH_METRICS_INTERVAL_SECONDS` | telemetry phase | no | `60` |
| `CLUSTERWATCH_METRICS_RESOURCE_USAGE_ENABLED` | telemetry phase | no | `true` |
| `CLUSTERWATCH_METRICS_KUBE_STATE_ENABLED` | telemetry phase | no | `true` |
| `CLUSTERWATCH_METRICS_KUBE_STATE_URL` | optional | no | `http://clusterwatch-kube-state-metrics.clusterwatch-agent.svc.cluster.local:8080/metrics` |
| `CLUSTERWATCH_METRICS_KUBE_STATE_TIMEOUT_SECONDS` | telemetry phase | no | `10` |
| `CLUSTERWATCH_METRICS_KUBELET_SUMMARY_ENABLED` | telemetry phase | no | `true` |
| `CLUSTERWATCH_REMEDIATION_ENABLED` | remediation phase | no | `false` |
| `CLUSTERWATCH_REMEDIATION_CLUSTER_WIDE` | remediation phase | no | `false` |
| `CLUSTERWATCH_REMEDIATION_ALLOWED_NAMESPACES` | remediation phase | no | `prod,platform` |
| `CLUSTERWATCH_REMEDIATION_ALLOWED_ACTIONS` | remediation phase | no | `rollout_restart` |
| `CLUSTERWATCH_REMEDIATION_POLL_INTERVAL_SECONDS` | remediation phase | no | `30` |
| `CLUSTERWATCH_LOG_LEVEL` | yes | no | `info` |
