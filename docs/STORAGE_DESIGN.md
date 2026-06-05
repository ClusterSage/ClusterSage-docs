# Storage Design

PostgreSQL is the system of record for metadata. Azure Blob Storage is the system of record for raw observability payloads.

## PostgreSQL Stores

- `organizations`: tenant boundaries.
- `users`: dashboard users and password hashes.
- `agent_keys`: hashed customer-installed agent keys.
- `clusters`: registered customer clusters and heartbeat state.
- `log_batches`: Blob paths and counts for log batches.
- `cluster_snapshots`: Blob paths for snapshots.
- `issues`: detected operational issues.
- `ai_recommendations`: future recommendation metadata, not raw secrets.
- `audit_logs`: security and operational audit trail.

## Blob Stores

The backend writes compressed JSON (`.json.gz`) to a private container named `clusterwatch-data`:

```text
logs/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/batch_<uuid>.json.gz
events/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/events_<uuid>.json.gz
snapshots/orgId=<org_id>/clusterId=<cluster_id>/year=<yyyy>/month=<mm>/day=<dd>/hour=<hh>/snapshot_<uuid>.json.gz
```

The customer agent never receives the storage connection string. Only the backend writes to Blob Storage.

## Verify Blobs

```bash
az storage blob list \
  --account-name <storage-account-name> \
  --container-name clusterwatch-data \
  --auth-mode login \
  --output table
```
