# Defaults catalog (decide these yourself; tag [assumed]; read only the relevant sections)

## Universal
- Layout: `src/<package>/` for source, `tests/` mirroring it, `docs/` for spec/plan/decisions, `scripts/` for tooling.
- Config: environment variables with a typed settings object; commit `.env.example`, never `.env`. No secrets in code.
- Logging: the language's standard logger, no bare `print` outside CLI output. Errors raised or returned explicitly at boundaries; no silent `except`/`catch`.
- Tests: one test per acceptance criterion at minimum; separate pure logic from I/O so logic is testable without UI, network, or disk.
- Git: `.gitignore` for the stack, small commits, conventional prefixes (`feat:`, `fix:`, `test:`, `chore:`).
- Docs: README with run, test, and build commands that really work.
- Dependencies: fewest possible; prefer the standard library when it is enough; pin versions via the lock file.

## Python
- Version 3.12+. Tooling: `uv` if present, otherwise `venv` + `pip`; metadata in `pyproject.toml`.
- Lint/format: `ruff`. Tests: `pytest`. Types: type hints everywhere; `mypy` only for M/L.
- Entry point: `python -m <package>`. Models: `dataclasses` (or `pydantic` for validated external input).
- Web service default: FastAPI. CLI default: `argparse` (stdlib) for small, `typer` for many commands.
- Games: pure game-state module (no rendering imports), separate renderer/input module, fixed-timestep update. Default UI when the user did not choose: ask (BLOCKER-lite): pygame (best feel, extra dependency), tkinter (stdlib, simple), terminal/curses (no GUI).

## TypeScript / Node
- Node LTS, `pnpm` if the lockfile says so, `strict: true`, ESLint + Prettier, Vitest (or Jest if already present).
- Web UI default: Vite + React for SPAs; Next.js only when SSR/SEO is requested.

## Persistence
- No persistence needed: do not add a database.
- Single user, local data: SQLite (stdlib in Python). Multi-user or deployed service: PostgreSQL. Migrations via the stack's standard tool.
- Access through a repository/storage module so tests can use an in-memory fake.

## Docker (when requested)
- Multi-stage build; slim pinned base image tag (no `latest`); run as a non-root user; `.dockerignore` mirroring `.gitignore`.
- Dependencies installed before copying source to use layer cache; `HEALTHCHECK` for services.
- `docker-compose.yml` only when more than one service (app + DB). Config via env vars, no secrets baked into the image.

## Web/API
- Validate all input at the boundary; consistent error format; no stack traces to clients; CORS closed by default.
- Auth only if the user wants accounts; then use a vetted library, hashed passwords, no home-made crypto.

## Audience
- Children: no accounts, no personal data collection, no analytics or ads, no external network calls unless required, large readable UI, no violence or dark patterns; mention this as a constraint in the spec.
- Internal tool: favor simplicity, SSO/hardcoded auth acceptable if the user says so, minimal UI polish.
- Public internet: input validation, rate limiting, dependency scanning, HTTPS terminated at the proxy, privacy basics.

## Performance and polish (only if the user cares)
- Do not optimize without a measured problem. Add a profiling step to the plan instead of guessing.
