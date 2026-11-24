---
name: docker-deploy
description: Use when containerizing an application, creating or editing Dockerfile, compose.yml / docker-compose.yml, .dockerignore, .env.example, or deployment/CI configs.
---

# docker-deploy

1. **Multi-stage `Dockerfile` (Python default):**
   - Pin an explicit slim base image tag (e.g., `FROM python:3.12-slim` — NEVER `:latest`).
   - Set `ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1`.
   - Copy dependency manifest (`pyproject.toml` / `requirements.txt`) and install BEFORE `COPY src/` so Docker layer cache holds.
   - Create and switch to a non-root user (`adduser --disabled-password --gecos "" appuser` + `USER appuser`).
   - Define `HEALTHCHECK` for long-running services (e.g., hitting `http://127.0.0.1:8000/health` via stdlib `urllib.request`).
   - Run via module entrypoint (`CMD ["python", "-m", "<package>"]` or `uvicorn ...`).
2. **`.dockerignore`:** exclude `.git/`, `.venv/`, `__pycache__/`, `*.pyc`, `.pytest_cache/`, `.ruff_cache/`, `tests/`, `docs/`, `memory-bank/`, `.clinerules/`, `.cline/`, `.env`, `*.egg-info/`.
3. **Config & Secrets:** read all config from environment variables; commit `.env.example` with every required var documented; NEVER bake `.env` or secrets into image layers.
4. **`compose.yml` (only when >1 service, e.g. app + postgres/redis):**
   - Pin service image tags (no `latest`), add `healthcheck` on backing services, use `depends_on: condition: service_healthy`, named volumes for persistent data, and `env_file` / explicit env mapping.
5. **Verify:**
   - Static checks run automatically in `scripts/check-structure.sh` (warns on missing `USER` or `:latest`).
   - If `docker` CLI & daemon are available, run `docker build -t <app>:smoke .` (and `docker compose config -q` if `compose.yml` exists); if Docker daemon is not running locally, state that clearly and test the entrypoint locally via `scripts/smoke.sh`.
