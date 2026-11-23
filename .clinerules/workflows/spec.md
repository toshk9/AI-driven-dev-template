# /spec.md — adaptive intake → brief → spec (Plan mode, no code)

Goal: learn only what matters, assume the rest by good practice, record everything.
Load the `project-intake` skill first: it has the triage rules and the defaults catalog.

1. EXTRACT. List what is already decided, from the user's message and from existing files (`memory-bank/*.md`, `.clinerules/10-stack.md`, README, manifests). Hand-written files and the user's own words always win. Tag these facts [stated].
2. SIZE the request:
   - S: small single-purpose program (example: "make a snake game in Python").
   - M: one app or service with several features.
   - L: several components, deployment, named principles, or the user lists many constraints.
3. TRIAGE every open question (see the skill):
   - BLOCKER: no sensible default exists, or a wrong guess is expensive to undo.
   - DEFAULT: a standard practice exists. Decide it yourself and tag it [assumed].
4. ASK, by size. Never more than this:
   - S: 0 questions if the product is clear; otherwise 1.
   - M: up to 3. L: up to 5.
   - Use ONE `ask_followup_question` call. Put a compact table of your [assumed] decisions in the question text and ask only about the BLOCKERs. Offer the options: "Accept defaults" first, then concrete alternatives.
   - Never ask about DEFAULT items one by one. If the user says "you decide", accept the defaults.
5. WRITE the files (no more questions for these):
   - `memory-bank/projectbrief.md`: what, who, features, out of scope.
   - `memory-bank/techContext.md` and `.clinerules/10-stack.md`: stack, commands, layout, conventions.
   - `.clinerules/15-principles.md`: only if the user named principles (SOLID, DDD, 12-factor, TDD...). Translate each into 2–4 checkable rules for THIS codebase (see the skill).
   - `docs/decisions.md`: one line per decision, tagged [stated] or [assumed], with a reason.
   - `docs/spec.md`: S up to 25 lines, M/L up to 80. Sections: Goal; Users and scenarios; Non-goals; Acceptance criteria `AC-1`.. (Given / When / Then, each testable); Interfaces; Constraints.
6. REPORT in at most 10 lines: the key decisions, marking every [assumed] one the user might care about.
   - S request: continue straight into `/plan.md`, then `/step.md` for S01, without waiting.
   - M/L request: ask the user to approve, then run `/plan.md`.

Do not write product code in this workflow.
