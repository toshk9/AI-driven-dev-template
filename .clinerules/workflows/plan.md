# /plan.md — break the spec into small steps (ACT mode: writes docs only)

Input: `docs/spec.md`. Output: `docs/plan.md`. No product code in this workflow.
This workflow only rewrites `docs/plan.md` (whole file, `write_to_file`) after the spec changed. A new project is closed by `bash scripts/intake-done.sh` inside `/spec.md`.

1. Read `docs/spec.md`, `.clinerules/10-stack.md`, `.clinerules/12-architecture.md`, and `memory-bank/repo-map.md` if present.
2. Write `docs/plan.md` as a checklist. One line per step:
   `- [ ] S01 | goal | real file paths (max 3) | test that proves it | AC-n`
3. Rules for steps:
   - `S01` = walking skeleton (thin entrypoint runs, one trivial end-to-end path, one passing test, initial `scripts/smoke.sh`).
   - Middle steps = vertical slices (one visible behavior each, not one horizontal layer). Group > ~6 modules into sub-packages (`domain/`, `adapters/`, `api/`, `agents/`, `tools/`).
   - Final step = end-to-end integration + `scripts/smoke.sh` runtime verification across all ACs (`AC-all`).
   - Each step: at most 3 files, <= ~150 changed lines, keeps `bash scripts/verify.sh` green.
   - A step may depend only on earlier steps; every `AC-n` in `docs/spec.md` maps to at least one step.
   - New dependencies or Docker/deploy configs are explicit steps.
4. Add a "Risks" section (max 5 lines): what is most likely to fail at runtime and which step tests it first.
5. Ask the user to review. Do not start implementing.
