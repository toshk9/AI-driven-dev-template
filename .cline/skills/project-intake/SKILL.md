---
name: project-intake
description: Use at the start of a new product or when a request describes a whole app, game, MAS, web service, CLI, or library, from either a one-line idea or a detailed brief. Triage what to ask the user versus decide by good practice, translate named principles like SOLID into checkable rules, and record decisions.
---

# project-intake

## 1. Triage: ask or decide?
Ask the user (`BLOCKER`) ONLY if ALL three are true:
- the answer changes the architecture, stack, or deliverable noticeably, AND
- there is no widely accepted default (or a wrong guess requires a rewrite), AND
- the answer cannot be inferred from the user's message or existing files.

Typical BLOCKERs:
- Core product behavior when vague (e.g., game rules, main API endpoints, agent workflow goal).
- Language/runtime or UI kind when not stated (CLI vs Web API vs Web UI vs Desktop GUI).
- Persistence or external integrations when state/providers are unclear (local SQLite vs PostgreSQL; which LLM/API provider).
- Deploy target when deployment is requested (single container vs multi-service Compose vs cloud target).
- Sensitive/regulated domain rules (children, payments, PII/health, auth).

Decide yourself (`DEFAULT`, tag `[assumed]`) for everything else: directory layout, sub-packages, test framework, linter, logging, config loading, error style, naming, Dockerfile internals, CI basics. Read only the relevant sections of `defaults.md` in this skill folder.

## 2. Reading the user's prompt
- **Detailed brief:** extract every stated requirement as `[stated]` and NEVER re-ask it. Usually 0–2 BLOCKERs remain.
- **One-line idea** (e.g., `"Make a Snake game in Python"`): apply best-practice defaults, ask at most 1 BLOCKER (e.g., GUI framework or missing core choice), and move on.
- **Named principles** (`SOLID`, `clean/hexagonal`, `TDD`, `12-factor`): translate them into checkable rules in `.clinerules/15-principles.md` (max 30 lines). Always add an anti-over-engineering guard (create abstractions only when two implementations exist or a test needs a seam).
- **Audience / compliance hints** (children, internal team, public internet): apply the Audience section of `defaults.md` and record constraints in `docs/spec.md` / `projectbrief.md`.

## 2b. Size the request
`S` one small program; `M` one app/service with several features or Docker; `L` multi-component system (MAS, API + DB + workers, deployment, named principles). Questions allowed in the single ask: S up to 1, M up to 3, L up to 5 (0 if nothing is ambiguous).

## 3. Asking well (at most ONE `ask_followup_question` call)
Put in the question text:
1. One line restating the product goal.
2. A compact table of your `[assumed]` defaults (so the user sees and can override them).
3. The BLOCKER question(s) (1 for S, <= 3 for M, <= 5 for L).
Options: `"Accept defaults (recommended)"` first, then 2–3 concrete alternatives with a brief tradeoff each.

## 4. Write (no more questions), whole files with `write_to_file`
`memory-bank/projectbrief.md` (max 20 lines), `.clinerules/10-stack.md` (real commands, layout, conventions), `.clinerules/15-principles.md` only if principles were named, `docs/spec.md` (M/L only: goal, scenarios, non-goals, `AC-1..` as Given/When/Then, constraints), `docs/plan.md`. Docker requested: add a dedicated Docker step. Then report in <= 10 lines. S: continue into `S01`. M/L: ask the user to approve the plan before product code.

## 5. Plan & Memory rules
- Record stack, layout, and key `[assumed]` / `[stated]` choices via `bash scripts/decide.sh "<decision>" <stated|assumed> "<reason>"`.
- `docs/plan.md`: `S01` MUST be a walking skeleton (thin entry point + passing test + `scripts/smoke.sh`). Final step MUST be an end-to-end integration & `scripts/smoke.sh` acceptance check across `AC-all`.
- Write memory files whole (`write_to_file`), never leave `{{...}}` placeholders, and close with `bash scripts/intake-done.sh "<one-line goal>"`.
