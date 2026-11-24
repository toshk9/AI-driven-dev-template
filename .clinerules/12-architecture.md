# Architecture and file structure (applies to every language; scripts enforce the limits)

- One module = one responsibility. A source file over 250 lines or a test file over 300 lines makes `verify.sh` fail (`scripts/gates.conf`). Functions: about 40 lines max.
- Entry point is thin (under 30 lines): it only wires modules together. No game or business logic in `main.py` / `__main__.py`.
- Layout: `src/<package>/` for code, `tests/` mirroring it: `src/pkg/bird.py` is tested by `tests/test_bird.py`. Never one big test file.
- Logic is pure and importable without UI, network, or disk: no framework imports (pygame, tkinter, flask, DOM) in logic modules. Framework code lives in separate `render` / `input` / `adapters` modules.
- Constants and tunable numbers live in one `config` module, not scattered as magic numbers.
- Example for a 2D game: `config.py`, `bird.py`, `pipes.py`, `collision.py`, `score.py`, `game.py` (state machine, no drawing), `render.py` (drawing only), `__main__.py` (wiring). Tests per logic module.
- A plan step lists these real paths. If a step needs a file that is not listed, fix the plan line first.
- Do not create abstractions without two implementations or a test that needs the seam.
