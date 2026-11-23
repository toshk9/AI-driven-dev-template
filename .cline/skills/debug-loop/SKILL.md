---
name: debug-loop
description: Use when a test, build, or command fails and the cause is not obvious, or when the same error appeared twice. A strict hypothesis-driven loop that prevents blind retries and endless edit cycles.
---

# debug-loop

Do not edit code until step 3.

1. **Capture & Diagnostic check**:
   - Run `serena:get_diagnostics_for_file` on suspected files to get instant LSP error context.
   - Capture the exact error text from terminal output (use `| tail -n 40`).
2. **Hypotheses**: write 2 or 3, ranked by likelihood. For each: the cheapest check that could disprove it (print statement, isolated single test, `git diff`).
3. **Check** the top hypothesis. Run its check. Record the result in one line.
4. **Fix** only after a hypothesis is confirmed. Use `serena:replace_symbol_body` or minimal `replace_in_file`.
5. **Re-run** the original command or `bash scripts/verify.sh`. If it still fails with the SAME error, the hypothesis was wrong: go back to step 2 with a new one. Never repeat the same edit or command.
6. After 2 full cycles with no progress: STOP, summarize what was ruled out, and ask the user.
