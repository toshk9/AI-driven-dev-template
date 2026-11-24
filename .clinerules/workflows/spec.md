# /spec.md: adaptive intake for a detailed or large request (ACT mode; writes docs only, no product code)

Goal: learn only what matters, decide the rest by good practice, record everything.
Load the `project-intake` skill first: it holds the triage rules and the defaults catalog.

1. EXTRACT what is already decided from the user's message and existing files. Tag it [stated]. The user's words always win.
2. SIZE the request. S: one small program. M: one app with several features. L: several components, deployment, named principles, many constraints.
3. TRIAGE open questions (see the skill): BLOCKER (no sensible default, expensive to undo) or DEFAULT (decide it yourself, tag [assumed]).
4. ASK by size, in ONE `ask_followup_question` call: S up to 1 question, M up to 3, L up to 5. The question text holds a compact table of your [assumed] decisions; ask only about BLOCKERs; first option is "Accept defaults". Never ask about DEFAULT items one by one.
5. WRITE (no more questions), each with `write_to_file`, whole file:
   - `memory-bank/projectbrief.md`: what, who, features, out of scope, stack.
   - `.clinerules/10-stack.md`: real commands, layout, conventions.
   - `.clinerules/15-principles.md`: only if the user named principles (SOLID, DDD, 12-factor...). Translate each into 2 to 4 checkable rules for THIS codebase (see the skill).
   - `docs/decisions.md`: one line per decision, [stated] or [assumed], with a reason.
   - `docs/spec.md`: S up to 25 lines, M/L up to 80. Goal; users and scenarios; non-goals; acceptance criteria `AC-1`.. (Given / When / Then, each testable); interfaces; constraints.
   - `docs/plan.md`: small steps, one line each: `- [ ] S01 | goal | files (max 3) | test | AC-n`. S01 is a walking skeleton, then vertical slices. Every AC maps to a step.
6. `bash scripts/intake-done.sh "<one-line goal>"`. If it prints INTAKE NOT DONE, do what it says and run it again.
7. REPORT in at most 10 lines: key decisions, marking each [assumed] one the user may care about.
   S request: continue straight into step S01. M/L request: ask the user to approve the plan first.
