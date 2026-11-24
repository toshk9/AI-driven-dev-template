# /step.md: implement the next plan step (ACT mode)

1. `read_file memory-bank/activeContext.md` (STATE must be ACTIVE; if it says NEW, do intake first) and `docs/plan.md`.
   Pick the first unchecked step, or the one the user named. Say which one in a single line.
2. Run `git status --short`. Python project without `.venv`: `bash scripts/setup-env.sh python`.
3. Do ONLY this step: read and change the files listed in its plan line (plus direct imports you need). No code of later steps.
   - Unfamiliar library API: context7 (see `06-mcp.md`), then the `api-lookup` skill.
   - Changing or renaming a signature: Serena "find referencing symbols" first.
4. Step larger than 3 files or about 150 lines: split it in `docs/plan.md` (distinct file paths per step), then continue with the first part.
5. Test first (skill `test-first`): write the test, run it, see it fail for the right reason.
6. Implement the minimum code to pass. Edit files with tools; never paste code into the chat.
7. Run `bash scripts/verify.sh` until `VERIFY OK` (max 2 fix attempts, then the debug-loop skill).
8. Dependency, entry point, or directory added? Rewrite `memory-bank/techContext.md` with `write_to_file` (whole file, max 30 lines).
9. FINISH and wait for the output:
   `bash scripts/finish-step.sh S03 "feat: S03 short summary" "next concrete action" "optional gotcha"`
   You may report the step only after you saw `STEP DONE`. If it printed STEP NOT DONE, fix what it says and run it again.
10. REMAINING steps and the user wants the whole project? Start the next step. `PLAN COMPLETE`? Call `attempt_completion` (max 5 lines; first line is the `STEP DONE ...` line).
    A single step was requested? Stop after `STEP DONE` and report in at most 5 lines.
