# /fix.md: fix a bug with proof (ACT mode)

1. `read_file memory-bank/activeContext.md`. Get the symptom: exact error text, steps, expected vs actual. Ask ONE question if something essential is missing.
2. Reproduce it with a failing test or the smallest command that shows the bug. Quote the failure.
3. Localize: Serena `get_diagnostics_for_file` (if listed in MCP SERVERS) or `search_files` for the error text, then read the narrow region. Write 2 or 3 hypotheses with the cheapest check for each; test the most likely first.
4. Fix the root cause with the smallest change. No refactoring around it.
5. Re-run the reproduction (it must pass), then `bash scripts/verify.sh`.
6. Same error twice: STOP and report hypotheses (debug-loop skill).
7. Finish and wait for `STEP DONE`:
   `bash scripts/finish-step.sh FIX "fix: <summary>" "<next action>" "<gotcha if the bug revealed one>"`
8. Report in at most 5 lines: root cause, the fix, the test that guards it, verify result.
