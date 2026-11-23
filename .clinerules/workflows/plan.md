# /plan.md — break the spec into small steps (use Plan mode)

Input: `docs/spec.md`. Output: `docs/plan.md`. No code in this workflow.

1. Read `docs/spec.md`, `.clinerules/10-stack.md`, and `memory-bank/repo-map.md` if present.
2. Write `docs/plan.md` as a checklist. One line per step:
   `- [ ] S01 | goal | files (max 3) | test that proves it | AC-n`
3. Rules for steps:
   - First steps: a walking skeleton (project runs, one trivial end-to-end path, tests run).
   - Then vertical slices: each step delivers one visible behavior, not one layer.
   - Each step is at most 3 files and about 150 changed lines, and leaves `bash scripts/verify.sh` green.
   - A step may depend only on earlier steps.
   - Every acceptance criterion maps to at least one step.
   - Setup and dependency steps are explicit steps (they need user approval).
4. Add a "Risks" section (max 5 lines): what is most likely to go wrong and which step checks it first.
5. Ask the user to review. Do not start implementing.
