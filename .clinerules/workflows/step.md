# /step.md: implement the next plan step (ACT mode)

1. `read_file memory-bank/activeContext.md` (STATE must be ACTIVE; if NEW, do intake first) and `docs/plan.md`.
   If locating existing files/symbols, also read `memory-bank/repo-map.md`. Pick the first unchecked step (or the one named) and state it in 1 line.
2. Run `git status --short`. Python project without `.venv`: `bash scripts/setup-env.sh python`.
3. Do ONLY this step: edit/create only the files listed in its plan line (forward slashes `/` only, never `\`). No code of later steps.
   - Unfamiliar 3rd-party library API: run `api-lookup` (installed version + `context7` / `help()`). Never guess APIs or coordinate systems.
   - Changing or renaming a signature: Serena `find_referencing_symbols` first.
4. Step larger than 3 files or ~150 lines? Split it in `docs/plan.md` first (distinct file paths per step), then continue with part 1.
5. Write the step's test together with the code (bug fix: failing test first).
6. Implement the minimum code to pass. Keep modules <= 250 lines (`12-architecture.md`). Never paste code into chat as the answer.
7. Ensure real wiring/smoke check works (`scripts/smoke.sh` if present or integration test), then run `bash scripts/verify.sh` until `VERIFY OK` (max 2 fix tries, then `debug-loop` skill).
8. Dependency, entry point, or directory added? Rewrite `memory-bank/techContext.md` (`write_to_file`, max 30 lines), and record new deps via `bash scripts/decide.sh`.
9. FINISH and wait for output:
   `bash scripts/finish-step.sh S03 "feat: S03 short summary" "next concrete action" "optional gotcha"`
   Report completion ONLY after seeing `STEP DONE`. Fix any `STEP NOT DONE` error and re-run.
10. REMAINING steps and building the whole project? Continue with `NEXT`.
    `PLAN COMPLETE`? Confirm all ACs + `scripts/smoke.sh` passed, then call `attempt_completion` (<= 5 lines; first line = `STEP DONE: ...`).
    Single step requested? Stop after `STEP DONE` and report in <= 5 lines.
