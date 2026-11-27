# Defaults catalog (decide these yourself; tag [assumed]; read only relevant sections)

## Universal
- Layout: `src/<package>/` + `tests/`, `docs/` (`spec.md`, `plan.md`, `decisions.md`), `scripts/` (`smoke.sh` + gate scripts). Split `src/<pkg>/` into sub-packages (`domain/`, `adapters/`, `api/`, `agents/`, `tools/`) once >= ~6 modules or distinct layers exist.
- Config: typed settings loaded from env vars (`pydantic-settings` or `dataclasses` + `os.environ`); commit `.env.example`, never `.env` or secrets.
- Logging: stdlib `logging` (structured key=value or JSON for services/MAS), no bare `print` outside CLI output. Raise/return explicit errors at boundaries; no silent `except`.
- Tests: unit tests per module + at least one non-mocked wiring/integration test + `scripts/smoke.sh` running the real entrypoint (`verify.sh` calls it automatically).
- Dependencies: fewest possible; prefer stdlib where sufficient; pin versions in `pyproject.toml` / lockfile.

## Layouts by project kind (inside `src/<pkg>/`; tests mirror them in `tests/`)
- Service / API: `config.py`, `domain/` (pure models and rules), `adapters/` (DB, HTTP, cache), `api/` (routes, schemas, `/health`), `__main__.py`; `tests/unit/` + `tests/integration/`.
- MAS / LLM app: `config.py`, `schemas/`, `prompts/`, `tools/`, `agents/`, `orchestrator/` (state and step budget), `llm/` (provider wrapper + fake), `__main__.py`.
- CLI / library: `config.py`, `core/`, `io/`, `cli.py`, `__main__.py`.
- Game / GUI: `config.py`, pure entity modules (`bird.py`, `pipes.py`, `collision.py`, `score.py`), `game.py` (state machine, no drawing), `render.py` and `input.py` (framework only), `__main__.py`.

## Python
- Version 3.12+. Project-local `.venv` via `scripts/setup-env.sh python`; all commands via `bash scripts/py.sh`. Metadata in `pyproject.toml`.
- Lint/format: `ruff`. Tests: `pytest`. Type hints on all public functions/models; `mypy` for M/L projects.
- Entry point: `python -m <package>` (`src/<package>/__main__.py`). Models: `dataclasses` (pure domain) or `pydantic` v2 (validated external I/O).
- CLI default: `argparse` (stdlib) for 1–2 commands, `typer` for multi-command CLIs.

## Web Services / Microservices / APIs
- Framework default: `FastAPI` + `uvicorn` + `pydantic` v2 (or `litestar` if requested).
- Endpoints: always expose `GET /health` (liveness) and `GET /ready` (readiness when DB/external deps exist). Use FastAPI `lifespan` for startup/shutdown.
- Errors & validation: validate all payloads at boundary with Pydantic; return consistent JSON error shape; never leak stack traces to clients; CORS closed by default.
- Testing: `fastapi.testclient.TestClient` / `httpx.AsyncClient` integration tests + `scripts/smoke.sh` hitting `/health`.

## Multi-Agent Systems (MAS) & LLM Workflows
- Load `.cline/skills/mas-architecture/SKILL.md` for full checklist.
- Defaults: explicit state model + `pydantic` tool/output schemas; `prompts/` separate from logic; `llm/` client behind a narrow protocol/interface so tests run deterministically offline with a fake LLM; hard `max_steps` / token / timeout guards on every agent loop; structured trace logging (`run_id`, `step`, `agent`, `tool`).

## Games / Desktop GUI
- Default library: `pygame` (or `pygame-ce`) for 2D arcade/action games (predictable API, top-left origin, easy `SDL_VIDEODRIVER=dummy` smoke tests); `tkinter` (stdlib) for simple desktop utilities. Use `arcade` only if the user asks for it, and ALWAYS verify installed version (`2.x` vs `3.x`) + `context7` first.
- Physics & rendering: pure state/physics module (zero UI imports), explicit `config.py` units (`PX_PER_SEC`, `GRAVITY_PX_PER_SEC2`), fixed/clamped `delta_time` in seconds, and documented coordinate origin (`y-down` vs `y-up`).
- Visuals: if no external image/sound assets exist, build layered vector/procedural shapes or generated surfaces + readable HUD/score/state overlays (avoid bare ugly single-color boxes unless prototyping), and verify headless frame stepping in `scripts/smoke.sh`.

## TypeScript / Node
- Node LTS, `pnpm` when lockfile present, `strict: true`, ESLint + Prettier, Vitest (or Jest if present).
- Web UI: Vite + React for SPAs; Next.js only when SSR/SEO is needed.

## Persistence
- Stateless app: no DB. Single-user local state: SQLite (`sqlite3` stdlib). Multi-user / deployed service: PostgreSQL + migrations (`alembic`).
- Wrap persistence behind a repository/storage interface so unit tests use an in-memory fake while integration tests exercise real SQL.

## Docker & Deployment (when requested)
- Load `.cline/skills/docker-deploy/SKILL.md`. Multi-stage build, pinned slim base tag (no `latest`), non-root user, `.dockerignore`, `HEALTHCHECK`, `compose.yml` only for multi-service stacks.

## Audience
- Children: no accounts, no PII, no analytics/ads, no unrequested external network calls, large readable UI, gentle feedback/no dark patterns.
- Internal tool: prioritize clarity & reliability over visual polish.
- Public internet: strict input validation, rate limiting, HTTPS at proxy, dependency/secret hygiene.
