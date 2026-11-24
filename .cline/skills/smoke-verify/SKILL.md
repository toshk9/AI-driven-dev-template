---
name: smoke-verify
description: Use when creating or updating scripts/smoke.sh or the final end-to-end verification step of a project. Provides short, reliable runtime smoke-test patterns for APIs, CLIs, MAS, libraries, GUIs/games, and Docker.
---

# smoke-verify

`scripts/verify.sh` automatically runs `bash scripts/smoke.sh` if it exists. Keep `scripts/smoke.sh` fast (under ~10 seconds), deterministic, offline-safe, and exit non-zero on any failure.

Choose the pattern that matches the app:

- **Python CLI (`src/<pkg>/__main__.py`):**
  ```bash
  set -eu
  bash scripts/py.sh -m <pkg> --help >/dev/null
  # plus one real sample invocation writing to a temp dir (cleanup via trap)
  ```
- **Web Service / FastAPI:**
  Run `TestClient` (or start `uvicorn` on an ephemeral port, poll `/health` with `py.sh -c "import urllib.request..."`, then kill PID in `trap`) and assert HTTP 200 + expected JSON keys.
- **Multi-Agent System (MAS) / AI Pipeline:**
  Run `bash scripts/py.sh -m <pkg> --dry-run` (or invoke the orchestrator entrypoint with `FakeLLMClient`) and assert exit code 0 + non-empty structured output.
- **2D Game / GUI (`pygame` / `arcade` / `tkinter`):**
  Run headless/offscreen for N frames (`SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy` for `pygame`, or `visible=False` for `arcade`) and assert: window/app initializes, `on_update(1/60)` advances game entities within expected bounds (no frozen motion, no instant out-of-bounds crash), and exits cleanly.
- **Library:**
  Import the public API from `src/<pkg>` in a fresh `bash scripts/py.sh -c "..."` subprocess and run the primary happy-path call end-to-end without mocks.

Always run `bash scripts/smoke.sh` after editing it and confirm exit code 0 before `finish-step.sh`.
