# /handoff.md — save state so a NEW task can continue cleanly

Run this when the task is long, or you hit the context limit, or the user asks.

1. Overwrite `memory-bank/activeContext.md` (max 25 lines) with:
   - Current step id and its state (not started / in progress / blocked)
   - Done in this task (bullets, with file paths)
   - Decisions made and why (1 line each)
   - Known gotchas and failing commands, with exact error text
   - Next action: one concrete command or edit
2. Make sure `docs/plan.md` checkboxes match reality.
3. Tell the user, in one line: open a new task and run `/step.md`.
