---
name: project-intake
description: Use at the start of a new product or when a request describes a whole app, game, service, or library, from either a one-line idea or a detailed brief. Triage what to ask the user versus decide by good practice, translate named principles like SOLID into checkable rules, and record decisions.
---

# project-intake

## Triage: ask or decide?
Ask the user (BLOCKER) only if ALL of these are true:
- the answer changes the architecture, the stack, or the deliverable noticeably, AND
- there is no widely accepted default, or a wrong guess costs a rewrite, AND
- the answer cannot be inferred from the user's words or existing files.

Typical BLOCKERs: what the product must actually do; language/platform when not stated; UI kind when a UI exists (terminal / desktop / web); where data lives when it must persist; deploy target when deployment is mentioned; legal-sensitive data (children, payments, health).

Decide yourself (DEFAULT) for everything else: project layout, test framework, linter, logging, config handling, error style, naming, Dockerfile details, CI basics. Use `defaults.md` in this skill folder. Read it only for the areas the project touches.

## Reading the user's message
- Detailed brief: extract every stated item as [stated] and do NOT re-ask it. Usually 0 or 1 questions remain.
- One-line idea: pick the best-practice defaults, ask at most 1 BLOCKER, and move on. A fast, reasonable build beats a long interview.
- Named principles ("SOLID", "clean architecture", "TDD", "12-factor"): translate them into rules (below). Never just claim compliance.
- Audience hints (children, internal team, public internet): apply the audience section of `defaults.md`.

## Translating principles into checkable rules (put in `.clinerules/15-principles.md`)
Write 2–4 rules per principle, each verifiable by reading code. Keep the result under 30 lines. Examples:
- SOLID, light version: one module has one reason to change; I/O (storage, clock, randomness, rendering, input) sits behind a small interface that tests can fake; dependencies are passed in via constructors, not created inside; prefer composition over inheritance.
- Anti over-engineering guard (always add with SOLID): create an abstraction only when there are two implementations or a test needs a seam. No generic frameworks for a small app.
- TDD: no production code without a failing test first (already enforced by `/step.md`).
- 12-factor: config from environment, logs to stdout, stateless processes.
- Clean/hexagonal: `domain/` has no imports from `infra/` or UI; direction of imports goes inward.

## Asking well
One `ask_followup_question`. The text contains: (1) one line restating the product, (2) a compact table of the [assumed] defaults, (3) the BLOCKER question(s). Options: "Accept defaults" first, then concrete alternatives with a one-phrase tradeoff each.

## Recording
Add one line per decision to `docs/decisions.md`: `D-n | decision | stated/assumed | reason | revisit if`.
Write memory files with `write_to_file` (whole file) and finish with `bash scripts/intake-done.sh`, which rejects files that still contain `{{...}}` placeholders. Keep `projectbrief.md` factual and short (max 20 lines). Mark assumptions with [assumed] so the user can find them later.
