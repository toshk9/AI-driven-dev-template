# Core rules for Qwen3.6-35B + Cline. Obey in this order. MEMORY FIRST.

Language: talk to the user in English. Code, comments, commits, docs: English.

## 0. BOOT: your FIRST tool call in EVERY task (before Serena, before anything else)
`read_file memory-bank/activeContext.md`, then act on its FIRST line:
- `STATE: NEW`: a new project. Do INTAKE (section 1). No product code before intake is done.
  (If the repo already has source code: `read_file .clinerules/workflows/init.md` and follow it instead.)
- `STATE: ACTIVE`: `read_file docs/plan.md`, then follow "Next action". Is the user's request new work (feature, change)?
  Add it to `docs/plan.md` as new step lines BEFORE coding. A bug? `read_file .clinerules/workflows/fix.md` and follow it.
- A question or explanation that changes no files: read memory, answer, skip sections 1 and 2.
The files are the truth about the project, not your guesses. If you keep a todo/progress checklist, its LAST item is "finish-step.sh".

## 1. INTAKE (STATE: NEW): memory before code. One tool call per message.
One-sentence request (a game, a tool, a script)? Ask NO questions. Choose best-practice defaults and mark them [assumed].
Detailed or large request? `read_file .clinerules/workflows/spec.md` and follow it.
1. `write_to_file memory-bank/projectbrief.md`, whole file, max 20 lines: what it is, who uses it, features, out of scope, stack.
2. `write_to_file .clinerules/10-stack.md`, whole file: the REAL run / test / lint commands, layout, conventions.
3. `write_to_file docs/plan.md`: 3 to 8 lines, `- [ ] S01 | goal | files (max 3) | test | AC-n`. S01 is a walking skeleton.
4. `bash scripts/intake-done.sh "<one-line goal>"`. It checks the three files, creates git and .venv, sets STATE: ACTIVE.
   If it prints INTAKE NOT DONE: do what it says and run it again. Only after INTAKE DONE write product code.

## 2. THE LOOP: one plan step at a time
1. Do ONE step from `docs/plan.md` (max 3 files, about 150 lines). Larger? Split it in `docs/plan.md` first.
2. TEST FIRST: write the test, run it, see it fail for the right reason.
3. IMPLEMENT the minimum code that passes.
4. FINISH with ONE command and wait for its output:
   `bash scripts/finish-step.sh S01 "feat: S01 short summary" "next concrete action" ["gotcha worth remembering"]`
   It verifies, ticks the plan, rewrites `memory-bank/activeContext.md`, and commits on `ai/work`.
   If it prints STEP NOT DONE: do what it says (it may ask you to write a memory file) and run it again.
5. After `STEP DONE`: it prints REMAINING and NEXT. Building a whole project? Continue with NEXT without stopping.
   Only when it prints `PLAN COMPLETE` call `attempt_completion`. Its FIRST line must be the `STEP DONE ...` line copied from the script.
   Do not claim a step is done without having seen STEP DONE. Never run `git commit` by hand.
6. Context getting long (about 25 tool calls) or you must stop: `bash scripts/finish-step.sh WIP "wip: summary" "next action" "state of the problem"`, then tell the user to open a new task.

## 3. Memory files
- Small files: change them with `write_to_file` (WHOLE file). Never `replace_in_file` on memory files.
- `activeContext.md` is script-owned: you only influence it through the arguments of finish-step.sh.
- `techContext.md`: write it before the first finish-step, and again whenever you add a dependency, entry point, or directory.
- `docs/decisions.md`: append one line for each non-obvious technical choice.

## 4. Tools (details in 05-env-git.md and 06-mcp.md)
- Existing code: search with Serena (`get_symbols_overview`, `find_symbol`, `find_referencing_symbols`) before `read_file`. Unfamiliar library API: context7.
- Empty project or new files: just `write_to_file`. Serena has nothing to index there.
- Serena `write_memory` / `read_memory` / `onboarding`: never use. Project memory is `memory-bank/`.
- Python: always `bash scripts/py.sh ...`, never bare python / pip / pytest.

## 5. Editing and grounding
- Never invent paths, functions, config keys, or library APIs. Check first. Read a file before editing it.
- Small edits: `replace_in_file` with a tiny exact SEARCH block (max 15 lines). New files or files under 80 lines: `write_to_file`.
- Deliver work only by changing files. Never paste code into the chat as the answer.
- Same command failed twice: STOP, write 3 hypotheses, change something structural before a third try.
- No new dependencies, config changes, or destructive commands (`rm -rf`, `git reset --hard`, `git push`) without the user's approval.

REMEMBER: first action = read `memory-bank/activeContext.md`. Last action = `scripts/finish-step.sh`. Nothing is done until you saw STEP DONE.
