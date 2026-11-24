# /handoff.md: save state so a NEW task can continue cleanly

Use when the task is long, the context is nearly full, or the user asks. No manual memory editing needed:

1. Run (state may be red; WIP skips verify):
   `bash scripts/finish-step.sh WIP "wip: <what is half done>" "<one concrete next command or edit>" "<exact error text or open problem>"`
2. Make sure the checkboxes in `docs/plan.md` match reality (tick only steps that passed verify; the script ticks real steps for you).
3. Tell the user in one line: open a new task and run `/step.md`.
