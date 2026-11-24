# Core rules for Qwen3.6-35B. Read fully and obey strictly.

## Language
- Talk to the user in English.
- Code, identifiers, code comments, commit messages, and docs: English.

## MCP & Serena Integration (PRIMARY TOOLS)
- **Symbol & Code Search:** ALWAYS use Serena MCP tools (`get_symbols_overview`, `find_symbol`, `find_referencing_symbols`) and `context7` before falling back to `read_file` or `search_files`.
- **Code Editing:** Prefer Serena LSP tools (`replace_symbol_body`, `insert_after_symbol`, `replace_lines`) for structure-aware edits. Fall back to `replace_in_file` only if Serena LSP does not support the target file type.
- **Session Start:** On the first tool call of a task, run `serena:initial_instructions` to activate project context.

# MEMORY FILES vs MCP MEMORY
- DO NOT use Serena `write_memory` tool for project context.
- ALWAYS use `write_to_file` or `replace_in_file` directly on `memory-bank/activeContext.md` and `docs/plan.md`.

## Gate 0: New Product Intake
- If `memory-bank/projectbrief.md` contains placeholders (e.g., `<one sentence>`), DO NOT write code. Execute `/spec.md` first.

## The Loop (Strict Order)
1. **ORIENT:** Read `memory-bank/activeContext.md` and `docs/plan.md`. Use Serena `get_symbols_overview` for relevant source files.
2. **ONE STEP:** Execute ONE atomic step from `docs/plan.md`. Max 3 files / 150 lines modified per step.
3. **TEST FIRST:** Write/adjust a failing test. Verify it fails.
4. **IMPLEMENT:** Apply minimal code via Serena LSP tools or `replace_in_file`.
5. **VERIFY:** Run `bash scripts/verify.sh` (or stack test command). Do not claim success without `VERIFY OK`.
6. **MANDATORY MEMORY SYNC:** Update `memory-bank/activeContext.md` with current progress and next steps.
7. **STOP:** Report completion in under 5 lines.

## MANDATORY COMPLETION GATE
CRITICAL: Calling `attempt_completion` WITHOUT a prior write to `memory-bank/activeContext.md` in the current task is FORBIDDEN.

## Grounding & Editing Rules
- Never invent paths, functions, or config keys.
- Small edits: `replace_in_file` with tiny SEARCH blocks (max 15 lines).
- Never rewrite large files completely (`write_to_file` only for new files or files < 80 lines).
- Stop rule: On 2 consecutive errors with the same command, stop and state 3 hypotheses. Do not attempt a 3rd execution without structural changes.
