# Core rules (Qwen3.6 + Cline). MEMORY FIRST. One tool call per message.

Reply in the user's language (English if unclear). Code, comments, commits, docs, memory files: English.

## 0. BOOT: first tool call of EVERY task, and again after any context summary or truncation
`read_file memory-bank/activeContext.md`, then act on its FIRST line:
- `STATE: NEW`: new project, do INTAKE (section 1). No product code before `INTAKE DONE`.
  Existing repo with source code: `read_file .clinerules/workflows/init.md` and follow it instead.
- `STATE: ACTIVE`: follow "Next action". Read `docs/plan.md` only to pick or change a step.
  New feature: add step lines to `docs/plan.md` BEFORE coding. Bug: `.clinerules/workflows/fix.md`.
- Question only (no edits): read memory, answer, skip sections 1 and 2.
After a summary or "history removed" notice: also `read_file memory-bank/repo-map.md` (all files and symbols in one read), and trust the files over your memory of the chat.

## 1. INTAKE (STATE: NEW)
1. `read_file .cline/skills/project-intake/SKILL.md`: it holds the whole procedure (size, triage, ask, write).
2. At most ONE `ask_followup_question` in total (recommended bundle first, "Accept defaults" option). Ask 0 if nothing is ambiguous.
3. Write whole files with `write_to_file`: `memory-bank/projectbrief.md`, `.clinerules/10-stack.md`, `docs/plan.md`.
   Plan line: `- [ ] S01 | goal | real file paths (max 3) | test | AC-n`. S01 = walking skeleton; last step = end-to-end check.
4. `bash scripts/decide.sh "<decision>" <stated|assumed> "<reason>"` for stack, layout, key assumptions.
5. `bash scripts/intake-done.sh "<one-line goal>"`. On `INTAKE NOT DONE`: fix and re-run.

## 2. LOOP: ONE plan step at a time
1. Do ONLY the current step: its files, its test. Never write code of later steps. One `write_to_file` <= ~150 lines.
2. EDITING: a NEW file: `write_to_file` (<= ~150 lines). An EXISTING source or test file: never rewrite it whole. Change only the lines you need:
   - one function or method: Serena `replace_symbol_body` (you output only that function), or `insert_after_symbol` to add one;
   - a few lines: `replace_in_file` with 1-3 small SEARCH blocks (3-6 lines each) copied exactly from the latest `read_file`.
   `replace_in_file` failed once: `read_file` that region again and retry with a smaller block. A whole-file rewrite is allowed only when more than half of the file changes, or for memory files.
3. New 3rd-party library? `api-lookup` skill first (installed version + context7). Never guess APIs.
4. Write the test and the code, run the step's test, then `bash scripts/verify.sh` until `VERIFY OK`.
   Bug fixes: the failing test comes first, and you must see it fail.
5. FINISH with one command and wait for its output:
   `bash scripts/finish-step.sh S01 "feat: S01 summary" "next concrete action" ["gotcha"]`
   On `STEP NOT DONE`: fix what it says, re-run. Never `git commit` by hand.
6. After `STEP DONE` do the `NEXT` step, unless the user asked for one step.
   At `PLAN COMPLETE` call `attempt_completion`; its first line is the `STEP DONE: ...` line, its last line offers the final audit (`/audit.md`) as the script says.
7. About 25 tool calls in one task, or blocked: `bash scripts/finish-step.sh WIP "wip: summary" "next action" "open problem"`, then ask the user to open a new task.

## 3. Questions during work (max 1 per step, 2-4 options, recommended first)
Only for: a new dependency, a design fork that changes later steps, an ambiguous requirement.
Record the answer with `decide.sh ... stated`. Never ask about naming, formatting, or what `docs/decisions.md` / `10-stack.md` already say.

## 4. Memory and tools
- Small memory files: rewrite whole with `write_to_file`, never `replace_in_file`. `activeContext.md` and `repo-map.md` are script-owned. `docs/decisions.md` only via `decide.sh`.
- Update `techContext.md` before the first finish-step and whenever dependencies, entry points or directories change.
- Env, git, Python wrapper: `05-env-git.md`. MCP: `06-mcp.md`. Same command failed twice: `debug-loop` skill.
- Never add dependencies, run destructive commands, or expose secrets without user approval.
