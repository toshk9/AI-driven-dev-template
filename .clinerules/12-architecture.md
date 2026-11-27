# Architecture (all languages; scripts enforce the limits)

- One module = one responsibility. Source files <= 250 lines, test files <= 300 (`scripts/gates.conf`, checked by `verify.sh`). Functions <= ~40 lines, shallow nesting.
- Thin entry point (<= 30 lines: `main.py` / `__main__.py` / `app.py`): wiring and lifecycle only, no business or game logic.
- Code in `src/<package>/`, tests in `tests/`. Group into sub-packages at ~6+ source files or distinct layers (layout examples per project kind: `.cline/skills/project-intake/defaults.md`).
- Pure core vs adapters: domain modules never import UI, network, LLM SDKs, DB drivers (`pygame`, `fastapi`, `httpx`, `openai`) and never read clock or random globals; pass those in at the boundary.
- Units and constants live in `config.py` with unit suffixes (`GRAVITY_PX_PER_SEC2`, `TIMEOUT_SEC`) and a documented coordinate origin. Every adapter has a real integration/smoke test.
- No empty or unused directories. No abstract base classes or factories until two implementations exist or a test needs the seam. A step needing a new path: update `docs/plan.md` first.
