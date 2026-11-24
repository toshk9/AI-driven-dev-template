# Stack and commands

- Language / runtime: Python 3.12
- Package manager: pip (via .venv)
- Run the app: `bash scripts/py.sh -m pygame_main` or `python -m src.game`
- Run one test file: `bash scripts/py.sh -m pytest tests/test_<name>.py -q`
- Run all tests: `bash scripts/py.sh -m pytest tests/ -q`
- Lint / typecheck: `bash scripts/py.sh -m ruff check .` (when added)
- Full gate: `bash scripts/verify.sh`

## Layout
- `src/` — game source code (bird, pipes, game engine, rendering)
- `tests/` — unit + integration tests
- `scripts/` — build/run/verify scripts
- `memory-bank/` — project memory files
- `docs/` — planning docs

## Conventions
- Naming: snake_case for functions/variables, PascalCase for classes
- Errors: raise descriptive exceptions, never silent fails
- Tests: unit tests for game logic, integration test for full game loop

