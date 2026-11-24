# /spec.md: adaptive intake for a detailed or large request (ACT mode; writes docs only, no product code)

Goal: learn only what matters, decide the rest by good practice, record everything.
Load `.cline/skills/project-intake/SKILL.md` first (triage rules and defaults catalog).
If Docker/deploy is requested, also skim `docker-deploy` skill; if MAS/LLM agents, skim `mas-architecture` skill.

1. EXTRACT what is already decided from the user's message and existing files. Tag `[stated]`. User's words always win.
2. SIZE the request:
   - `S`: one small program/script.
   - `M`: one app/service with several features or Docker.
   - `L`: multi-component system (MAS, API + DB + workers, deployment, named principles, many constraints).
3. TRIAGE open questions (per `project-intake`): BLOCKER (expensive to undo, no obvious default) vs DEFAULT (decide yourself, tag `[assumed]`).
4. ASK by size, in ONE `ask_followup_question` call: `S` up to 1 question, `M` up to 3, `L` up to 5 (0 if nothing is ambiguous).
   Put a compact table of `[assumed]` defaults in the question text; ask only BLOCKERs; first option = `"Accept defaults (recommended)"`. Never ask DEFAULT items one by one.
5. WRITE (no more questions), each with `write_to_file`, whole file:
   - `memory-bank/projectbrief.md` (max 20 lines): what, who, features, out of scope, stack.
   - `.clinerules/10-stack.md`: real run / test / lint commands, sub-package layout (`12-architecture.md`), conventions.
   - `.clinerules/15-principles.md`: ONLY if the user named principles (SOLID, Clean/Hexagonal, TDD, 12-factor). Translate each into 2–4 checkable rules for THIS repo (max 30 lines).
   - Decisions: call `bash scripts/decide.sh "<decision>" <stated|assumed> "<reason>"` for stack, layout, and key `[assumed]` choices.
   - `docs/spec.md` (`S` <= 25 lines, `M`/`L` <= 80 lines): goal; users & scenarios; non-goals; acceptance criteria `AC-1..` (Given / When / Then, testable); interfaces/schemas; constraints (audience, security, deploy).
   - `docs/plan.md`: small vertical steps (`- [ ] S01 | goal | real file paths (max 3) | test | AC-n`).
     `S01` = walking skeleton (thin entry point + passing test + `scripts/smoke.sh`).
     Final step = end-to-end integration/smoke & acceptance verification (`AC-all`).
     If Docker/deploy is requested, include a dedicated Docker step (`Dockerfile`, `.dockerignore`, `.env.example`, `compose.yml` if multi-service).
6. CLOSE INTAKE: `bash scripts/intake-done.sh "<one-line goal>"`. Fix any `INTAKE NOT DONE` error and re-run.
7. REPORT in <= 10 lines: key decisions (marking `[assumed]` ones).
   - `S` request: proceed straight into `S01` and do ONLY `S01`.
   - `M`/`L` request: ask the user to approve the plan before writing product code.
