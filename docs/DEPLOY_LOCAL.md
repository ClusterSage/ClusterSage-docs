# Local Docker Compose Deployment

Use this for development on a workstation. It starts frontend, backend, PostgreSQL, and Azurite for local Blob-compatible storage.

## Prerequisites

- Docker Desktop or Docker Engine with Compose v2.
- Ports `3000`, `8000`, `5432`, and `10000` available.

## Start

```bash
docker compose up -d
docker compose logs -f backend
docker compose exec backend alembic upgrade head
curl http://localhost:8000/health
```

Open `http://localhost:3000`, register, log in, and generate an agent key.

## Stop

```bash
docker compose down
```

Delete local data only when you are sure:

```bash
docker compose down -v
```

## Troubleshooting

```bash
docker compose ps
docker compose logs -f postgres
docker compose logs -f azurite
docker compose exec backend python -m alembic current
```
