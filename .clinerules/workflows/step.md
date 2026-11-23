# /step.md — implement the next step (use Act mode)

1. Read `memory-bank/activeContext.md` and `docs/plan.md`. Pick the first unchecked step, or the one the user named. Say which one in a single line.
2. Read ONLY the files listed in the step, plus direct imports you actually need. If an API is unfamiliar, use the `api-lookup` skill.
3. If the step is larger than 3 files or about 150 lines: stop, propose a split, wait.
4. Test first: write or adjust the test, run it, confirm it fails for the right reason.
5. Implement the minimum code to pass.
6. Run `bash scripts/verify.sh`. If it fails, fix (max 2 attempts), then follow the Stuck rule.
7. Check your own diff: `git diff --stat`, then `git diff` if it is small. Remove debug output and stray changes.
8. Tick the step in `docs/plan.md`; update `memory-bank/activeContext.md` (max 15 lines: done, next, gotchas).
9. If the user allowed auto-commit: `git add -A && git commit -m "<type>: <summary>"`. Otherwise propose the message.
10. `attempt_completion`, max 5 lines: what changed, verify result, next step id. If this task has used more than about 50% of the context, tell the user to continue in a new task.
