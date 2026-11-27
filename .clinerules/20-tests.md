---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/test_*.py"
  - "tests/**"
  - "test/**"
  - "scripts/smoke.sh"
---
# Tests and verification

- One behavior per test, named `<unit>_<does_what>_when_<condition>`; Arrange / Act / Assert; no loops or branching in test bodies. Assert observable behavior, not private attributes or mock call counts.
- Copy the structure of the nearest existing test. Fake clock, randomness, network and LLM calls in unit tests.
- Never edit a test just to make broken code pass; if the spec changed, say so.
- Runnable apps MUST also have: (1) an integration test through real wiring (`TestClient`, CLI subprocess, orchestrator with a fake LLM, or game `update(dt)` over many frames checking real movement/collision); (2) `scripts/smoke.sh`, run by `verify.sh`, which starts the real entrypoint headless with a short timeout and exits 0 only if it runs cleanly (patterns: `.cline/skills/smoke-verify/SKILL.md`).
- Run the affected test, then `bash scripts/verify.sh`, before every `finish-step.sh`.
