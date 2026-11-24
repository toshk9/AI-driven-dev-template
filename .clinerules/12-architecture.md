# Architecture and file structure (applies to every language; scripts enforce the limits)

- **One module = one responsibility.** Source files <= 250 lines, test files <= 300 lines (`scripts/gates.conf` -> `verify.sh` fails above this). Keep functions <= ~40 lines with shallow nesting.
- **Thin entry point (<= 30 lines):** `main.py` / `__main__.py` / `app.py` only wires config, dependencies, and lifecycle. Zero business, game, or orchestration logic in the entrypoint.
- **Mirror layout (`src/` + `tests/`):** code lives under `src/<package>/`, tests under `tests/`. Group into sub-packages once a project has ~6+ source files or distinct architectural layers:
  - **Services / APIs:** `config.py`, `domain/` (pure models & rules), `adapters/` or `infra/` (DB, HTTP, cache), `api/` (routes, schemas, `/health`), `__main__.py`; tests in `tests/unit/` + `tests/integration/`.
  - **Multi-Agent Systems (MAS) / LLM apps:** `config.py`, `schemas/` (Pydantic contracts), `prompts/`, `tools/`, `agents/`, `orchestrator/` (state & step budget), `llm/` (provider wrapper + fakeable interface), `__main__.py`.
  - **CLI / Libraries:** `config.py`, `core/`, `io/`, `cli.py`, `__main__.py`.
  - **Games / GUI:** `config.py`, pure `domain/` or entity modules (`bird.py`, `pipes.py`, `collision.py`, `score.py`), `game.py` (state machine, no drawing), `render.py` / `input.py` (framework-only), `__main__.py`.
- **Pure core vs adapters:** core/domain modules must NEVER import UI, network, LLM SDKs, DB drivers, or clock/random globals (`pygame`, `arcade`, `fastapi`, `httpx`, `openai`). Pass dependencies/clocks/RNG in at boundaries so core logic tests cleanly without I/O.
- **Explicit units & contracts:** all constants, tunable values, and coordinate/unit conventions live in `config.py` with unit suffixes or docstrings (e.g., `GRAVITY_PX_PER_SEC2`, `TIMEOUT_SEC`, origin convention). Adapters convert at the boundary and MUST have a real integration/smoke test.
- **No accidental junk or premature abstractions:** never create empty/unused directories; never add abstract base classes/factories until two implementations exist or a test needs the seam. Plan steps list real paths; update `docs/plan.md` first if a step needs a new path.
