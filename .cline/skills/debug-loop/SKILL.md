---
name: debug-loop
description: Use when a test, build, or command fails and the cause is not obvious, or when the same error appeared twice. A strict hypothesis-driven loop that prevents blind retries and endless edit cycles.
---

# debug-loop

Do not edit code until step 4.

1. **Capture and diagnose.**
   - If Serena lists `get_diagnostics_for_file`, run it on the suspected files for instant LSP error context.
   - Capture the exact error text from the terminal (use `| tail -n 40`).
2. **Hypotheses.** Write 2 or 3, ranked by likelihood. For each: the cheapest check that could disprove it (a print, an isolated single test, `git diff`).
3. **Check** the top hypothesis. Run its check. Record the result in one line.
4. **Fix** only after a hypothesis is confirmed, with the smallest edit: `replace_in_file`, or a Serena symbol edit for one existing function.
5. **Re-run** the original command or `bash scripts/verify.sh`. Same error again means the hypothesis was wrong: back to step 2 with a new one. Never repeat the same edit or command.
6. After 2 full cycles with no progress: STOP, summarize what was ruled out, ask the user. If the task is long, save state first: `bash scripts/finish-step.sh WIP "wip: <summary>" "<next action>" "<exact error>"`.
