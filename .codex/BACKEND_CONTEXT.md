# Backend Context

Backend path: `apps/backend`. It uses FastAPI, async SQLAlchemy, Alembic, JWT, bcrypt, Azure Blob Storage SDK, request body limits, rate-limit middleware, and structured logging. Endpoints are implemented in route modules under `app/auth`, `app/agent_keys`, `app/agents`, `app/ingestion`, `app/clusters`, and `app/audit`. The initial database migration is `0001_initial.py`.

Agent keys are shown once and stored hashed. Agent tokens are JWTs signed with `AGENT_TOKEN_SECRET`.
