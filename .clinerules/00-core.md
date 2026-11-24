# Core rules for Qwen3.6-35B + Cline. Obey in this order. MEMORY FIRST.

Language: talk to the user in English. Code, comments, commits, docs: English.

## 0. BOOT: your FIRST tool call in EVERY task (before Serena, before anything else)
`read_file memory-bank/activeContext.md`, then act on its FIRST line:
- `STATE: NEW`: a new project. Do INTAKE (section 1). No product code before intake is done.
  (If the repo already has source code: `read_file .clinerules/workflows/init.md` and follow it instead.)
- `STATE: ACTIVE`: `read_file docs/plan.md`, then follow "Next action". Is the user's request new work (feature, change)?
  Add it to `docs/plan.md` as new step lines BEFORE coding. A bug? `read_file .clinerules/workflows/fix.md` and follow it.
- A question or explanation that changes no files: read memory, answer, skip sections 1 and 2.
RUN BOOT AGAIN (read activeContext.md, docs/plan.md, `git status --short`) whenever your context starts with a SUMMARY of earlier work
(context was compacted), or when you are unsure which step you are on. Trust those files over the summary and over your memory.
If you keep a todo/progress checklist, its LAST item is "finish-step.sh".

## 1. INTAKE (STATE: NEW): memory before code. One tool call per message.
1. STACK. Language and framework stated by the user? Use them. NOT stated? Ask ONE `ask_followup_question` now, before writing anything.
   Options = 3 to 4 complete stack bundles, your recommendation first and marked "(recommended)", for example
   "Python + pygame (recommended)", "Python + tkinter", "JavaScript + HTML canvas (browser)". The user may type another answer.
   Ask nothing else (layout, tests, linter): decide by best practice and record it. Detailed or large request: `read_file .clinerules/workflows/spec.md` and follow it.
2. `write_to_file memory-bank/projectbrief.md`, whole file, max 20 lines: what it is, who uses it, features, out of scope, stack.
3. `write_to_file .clinerules/10-stack.md`, whole file: the REAL run / test / lint commands, layout (the module tree), conventions.
4. `write_to_file docs/plan.md`: 4 to 8 lines, `- [ ] S01 | goal | file paths, comma separated | test | AC-n`.
   The files column holds real PATHS (`src/pkg/bird.py, tests/test_bird.py`), never class names. One module per responsibility
   (see 12-architecture.md). S01 is a walking skeleton: thin entry point plus one passing test.
5. `bash scripts/decide.sh "<stack and layout>" <stated|assumed> "<reason>"`: records the decision in `docs/decisions.md`.
6. `bash scripts/intake-done.sh "<one-line goal>"`. It checks the files and the plan, creates git and .venv, sets STATE: ACTIVE.
   INTAKE NOT DONE means: do what it says and run it again. Only after INTAKE DONE write product code.

## 2. THE LOOP: ONE plan step at a time
1. Do ONLY the current step: its files, its behavior, its test. NEVER write code that belongs to a later step.
   One `write_to_file` call: at most about 150 lines. Bigger means split it into modules.
2. TEST FIRST: write the test, run it, see it fail for the right reason. 3. IMPLEMENT the minimum that passes.
4. FINISH with ONE command and wait for its output:
   `bash scripts/finish-step.sh S01 "feat: S01 short summary" "next concrete action" ["gotcha worth remembering"]`
   It checks memory, scope, tests, verify; ticks the plan; rewrites `memory-bank/activeContext.md`; commits on `ai/work`.
   STEP NOT DONE means: do what it says and run it again. It will refuse a step that changed files of other steps or no files at all.
5. After `STEP DONE` it prints REMAINING and NEXT. Building a whole project? Continue with NEXT, one step at a time.
   At `PLAN COMPLETE` call `attempt_completion`; its FIRST line is the `STEP DONE ...` line copied from the script.
   Do not claim a step is done without having seen STEP DONE. Never run `git commit` by hand.
6. Context long (about 25 tool calls) or you must stop: `bash scripts/finish-step.sh WIP "wip: summary" "next action" "state of the problem"`, then tell the user to open a new task.

## 3. Questions during work (`ask_followup_question`, at most one per step, 2 to 4 options, recommended first)
Ask when: a new dependency is needed; a design choice has 2 or more viable options and changes later steps; the request is ambiguous in a way that changes the result.
After the answer: `bash scripts/decide.sh "<choice>" stated "<what the user said>"`.
Do NOT ask about naming, layout, test style, formatting, or anything already in `docs/decisions.md` or `10-stack.md`.

## 4. Memory files
- Small files: change them with `write_to_file` (WHOLE file). Never `replace_in_file` on memory files.
- `activeContext.md` is script-owned: you influence it only through the arguments of finish-step.sh.
- `docs/decisions.md` only through `scripts/decide.sh`. `techContext.md`: write it before the first finish-step and whenever dependencies, entry points, or directories change.

## 5. Tools (details in 05-env-git.md and 06-mcp.md)
- Existing code: Serena (`get_symbols_overview`, `find_symbol`, `find_referencing_symbols`) before `read_file`. Unfamiliar library API: context7.
- Empty project or new files: `write_to_file`. Serena `write_memory` / `read_memory` / `onboarding`: never. Project memory is `memory-bank/`.
- Python: always `bash scripts/py.sh ...`, never bare python / pip / pytest.
- Never invent paths, functions, config keys, or library APIs; check first. Read a file before editing it.
- Edits: `replace_in_file` with a tiny exact SEARCH block (max 15 lines). New files: `write_to_file`. Never paste code into the chat as the answer.
- Same command failed twice: STOP, write 3 hypotheses, change something structural before a third try.
- No new dependencies, config changes, or destructive commands (`rm -rf`, `git reset --hard`, `git push`) without the user's approval.

REMEMBER: first action = read `memory-bank/activeContext.md` (and again after any context summary). Last action = `scripts/finish-step.sh`. One step at a time. Nothing is done until you saw STEP DONE.
