# /fix.md — fix a bug with proof

1. Get the symptom: exact error text, steps, expected vs actual. Ask ONE question if something essential is missing.
2. Reproduce it with a failing test or the smallest command that shows the bug. Quote the failure.
3. Localize: use `search_files` for the error text or symbol, then read the narrow region. Write 2 or 3 hypotheses and the cheapest check for each. Test the most likely first.
4. Fix the root cause with the smallest change. Do not refactor around it.
5. Re-run the reproduction (it must pass), then `bash scripts/verify.sh`.
6. Same error twice means STOP and report hypotheses (Stuck rule).
7. Report in max 5 lines: root cause, the fix, the test that guards it, verify result. Update `memory-bank/activeContext.md` if the bug revealed a gotcha.
