# /audit.md: final deep audit (ACT mode; run it only after PLAN COMPLETE and a green verify)

User: set reasoning effort to MAXIMUM and Max Output Tokens to 16000+ in Cline first (thinking is cut off at the output limit). Expect about 3-6 minutes per module.
Product files stay read-only until every module is reviewed (phase 1); fixes happen in phase 2. State lives in `docs/audit.md`, so after a context reset: `read_file memory-bank/activeContext.md`, then `bash scripts/audit.sh status`.

## Phase 1: review
1. `bash scripts/audit.sh start`. Read the goal and AC in `memory-bank/projectbrief.md` (and `docs/spec.md` if present) once.
2. For EVERY module in the list, one at a time: `read_file` the whole file (and its test), think hard, then record each real problem:
   `bash scripts/audit.sh add <path> <BUG|RISK|NIT> "<what is wrong>" "<concrete failure: input or state -> wrong result>"`
   then `bash scripts/audit.sh seen <path>`. A finding without a concrete failure scenario is not allowed (the script refuses it). Do not report style preferences as BUG.
   Look through these lenses, in order:
   - Spec: does the code satisfy each AC, including the unlikely cases the tests do not cover?
   - Logic: off-by-one, wrong comparison, inverted condition, unit mix-ups (px vs px/s, ms vs s), state that is never reset, shared mutable defaults, integer vs float division.
   - Boundaries and errors: empty, zero, negative, huge, missing file, bad input, exceptions swallowed or leaking, resources never closed.
   - Lifecycle and time: frame-rate dependence (movement must use dt), ordering of update and render, restart or game-over path leaves old state, timers, race or re-entrancy.
   - Library use: wrong or deprecated API, argument order, return type. Unsure: context7 or the installed package source, never memory.
   - Security (anything with input, files, network, LLM output): injection, path traversal, secrets, unsafe deserialization, unbounded loops or retries.
   - Tests: tests that assert nothing, mock away the thing under test, or never fail. A real behavior with no test is a RISK.
3. Trace the main flow end to end with real numbers (for a game: 3 frames of input -> update -> collision -> score -> render; for a service: one request through every layer). Record it: `bash scripts/audit.sh flow "<name>" "<trace and result>"`.
4. `bash scripts/audit.sh status` shows what is still open.

## Phase 2: fix (only BUG and RISK)
For each open finding: write a test that fails for the stated reason, fix the code with the smallest edit, then
`bash scripts/finish-step.sh FIX "fix: F-<n> <summary>" "continue audit: bash scripts/audit.sh status"`
and `bash scripts/audit.sh resolve F-<n> fixed "<test name that now passes>"`. A finding you checked and found to be wrong: `resolve F-<n> rejected "<why it is not a bug>"`. Never "fix" by deleting or weakening a test.

## Finish
`bash scripts/audit.sh done` (needs every module seen, a traced flow, no open BUG/RISK, verify green). Then `attempt_completion`: first line is the `AUDIT DONE: ...` line, then at most 5 lines: what was fixed, what remains as NIT or RISK the user should know.
