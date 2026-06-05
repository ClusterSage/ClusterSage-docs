# Storage Context

Use one private Blob container named `clusterwatch-data`. Blob prefixes include org and cluster IDs. PostgreSQL rows index Blob paths and store metadata. Backend `app/storage/blob.py` writes compressed JSON. The agent only posts to backend ingestion APIs.
