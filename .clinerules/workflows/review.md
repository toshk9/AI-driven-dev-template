# /review.md — review the current diff (best in a fresh task)

1. `git diff --stat`. If the diff is over ~400 lines, review file by file with `git diff -- <file>`.
2. Read `docs/spec.md` (or `memory-bank/projectbrief.md`), `docs/decisions.md`, and `memory-bank/techContext.md`.
3. Check each item and note only real findings:
   - Acceptance criteria: does the diff actually satisfy every AC end-to-end, or only mocked unit tests?
   - Runtime contracts: units/time scaling (`dt` in sec vs per-frame), coordinate origin, API schemas, env var names match `.env.example`.
   - Scope & cleanliness: unrelated edits, unused/empty directories, leftovers (debug prints, commented-out code, unowned TODOs).
   - Architecture & boundaries: core logic free of UI/network/LLM/DB imports; files <= 250 lines; error handling at boundaries.
   - Tests & smoke: tests assert behavior, cover failure paths, not edited just to pass; `scripts/smoke.sh` exercises real entrypoint without crashes.
   - Security & deploy: no secrets, safe SQL/shell/paths, Dockerfile non-root & pinned base tag (if present).
4. Output a list: `BLOCKER | file:line | problem | fix` and `NIT | file:line | note`.
5. Fix BLOCKERs only after the user agrees. Re-run `bash scripts/verify.sh`.
