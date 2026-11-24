---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/test_*.py"
  - "tests/**"
  - "test/**"
  - "scripts/smoke.sh"
---
# Testing & verification rules (unit + real integration/smoke)

- **Unit tests:** one behavior per test, named `<unit>_<does_what>_when_<condition>`. Arrange / Act / Assert, no loops or branching logic inside test bodies.
- **Assert observable behavior**, never private attributes or mock call counts unless the call IS the contract.
- **Deterministic core tests:** inject or fake clock, randomness, network, and LLM calls in unit tests.
- **Test first:** write the failing test, run it, confirm it fails for the missing behavior (not import/syntax error), then implement the minimum to pass.
- **Never edit an existing test just to make a broken implementation pass.** If the spec changed, say so and update explicitly.
- **Real integration & smoke test (MANDATORY for runnable apps):** unit mocks never catch wrong units (`dt` per-frame vs per-second), inverted coordinates, broken DI wiring, or 3rd-party API mismatches. Every runnable app MUST also have:
  1. At least one **integration test** exercising real boundary wiring (`FastAPI` `TestClient`, CLI subprocess, MAS orchestrator with deterministic fake LLM, or GUI/game `on_update(dt)` ticking multiple frames and checking real movement/collision/state).
  2. **`scripts/smoke.sh`** (invoked automatically by `scripts/verify.sh`): starts or imports the real entrypoint (`--help`, `/health`, headless/offscreen frames, or sample pipeline run) with a short timeout and exits 0 only if it boots cleanly without crashing.
- Iterate on the affected test file; run `bash scripts/verify.sh` before every `finish-step.sh`.
