# Smoke Tests

Set the API URL:

```bash
export API_URL="http://localhost:8000"
```

## Backend

```bash
curl "$API_URL/health"
```

## Register User

```bash
curl -X POST "$API_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"Password@123","full_name":"Demo User","organization_name":"Demo Org"}'
```

## Login User

```bash
export JWT=$(curl -s -X POST "$API_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"Password@123"}' | python -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
```

## Create Agent Key

```bash
export AGENT_KEY=$(curl -s -X POST "$API_URL/api/agent-keys" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{"name":"smoke-test-key"}' | python -c "import sys,json; print(json.load(sys.stdin)['raw_key'])")
echo "$AGENT_KEY"
```

## Register Agent

```bash
export AGENT_TOKEN=$(curl -s -X POST "$API_URL/api/agent/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"demo@example.com\",\"access_key\":\"$AGENT_KEY\",\"cluster_name\":\"smoke-cluster\",\"provider\":\"aks\",\"agent_version\":\"0.1.0\"}" | python -c "import sys,json; print(json.load(sys.stdin)['agent_token'])")
```

## Send Heartbeat

```bash
curl -X POST "$API_URL/api/agent/heartbeat" \
  -H "Authorization: Bearer $AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"healthy","agent_version":"0.1.0"}'
```

## Send Sample Logs

```bash
curl -X POST "$API_URL/api/ingest/logs" \
  -H "Authorization: Bearer $AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"logs":[{"namespace":"default","pod":"demo","container":"app","message":"hello from smoke test"}]}'
```

## Send Snapshot With Issue

```bash
curl -X POST "$API_URL/api/ingest/snapshot" \
  -H "Authorization: Bearer $AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"snapshot_type":"full","snapshot":{"pods":[{"metadata":{"namespace":"default","name":"bad-pod"},"status":{"phase":"Running","containerStatuses":[{"name":"app","restartCount":6,"state":{"waiting":{"reason":"CrashLoopBackOff","message":"container is restarting"}}}]}}],"nodes":[],"deployments":[],"persistentvolumeclaims":[]}}}'
```

## Verify Blob Upload

```bash
az storage blob list \
  --account-name <storage-account-name> \
  --container-name clusterwatch-data \
  --auth-mode login \
  --output table
```

## Verify Database Records

```sql
SELECT * FROM users;
SELECT * FROM organizations;
SELECT * FROM clusters;
SELECT * FROM log_batches;
SELECT * FROM issues;
```
