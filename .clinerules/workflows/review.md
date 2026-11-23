# /review.md — review the current diff (best in a fresh task)

1. `git diff --stat`. If the diff is over about 400 lines, review it file by file with `git diff -- <file>`.
2. Read `docs/spec.md` acceptance criteria that relate to the change.
3. Check each item and note only real findings:
   - Does the change satisfy its acceptance criteria? Is anything missing?
   - Scope creep: unrelated edits, reformatting, new dependencies.
   - Leftovers: debug prints, commented-out code, TODOs without an owner.
   - Error handling at boundaries (I/O, parsing, network); inputs validated.
   - Tests: assert behavior, cover the failure path, not edited just to pass.
   - Secrets, unsafe shell or SQL construction, path handling.
4. Output a list: `BLOCKER | file:line | problem | fix` and `NIT | file:line | note`.
5. Fix BLOCKERs only after the user agrees. Re-run `bash scripts/verify.sh`.
