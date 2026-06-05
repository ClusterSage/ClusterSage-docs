# Architecture Context

The SaaS backend owns identity, validation, storage writes, metadata, and issue detection. The customer agent owns Kubernetes reads and log forwarding. PostgreSQL stores metadata and indexes; Azure Blob Storage stores raw compressed logs/events/snapshots under tenant-scoped prefixes. Frontend renders the install guide from the logged-in user and generated agent key.
