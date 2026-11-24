# AI-driven dev template (Cline + local Qwen3.6-35B-A3B)

Project skeleton that makes a small local model work like a disciplined engineer:
small steps, tests first, one quality gate, and project memory that is enforced by scripts, not by hope.

## How the memory works
| File | Written by | Read when |
|---|---|---|
| `memory-bank/activeContext.md` (line 1: `STATE: NEW` or `STATE: ACTIVE`) | `scripts/intake-done.sh`, `scripts/finish-step.sh` | FIRST tool call of every task |
| `memory-bank/projectbrief.md`, `.clinerules/10-stack.md`, `docs/plan.md` | the model (`write_to_file`) at intake | `10-stack.md` is auto-loaded; others at boot |
| `memory-bank/techContext.md` | the model, at first finish and when dependencies change | when touching deps or entry points |
| `docs/decisions.md` | `scripts/decide.sh` (required at intake, and whenever a dependency is added) | when choosing a library or architecture |

Placeholders are `{{...}}`. Scripts refuse to continue while any remain, so a skipped memory write shows up as an error message the model must act on.

## Flow
```
new project:  read activeContext (STATE: NEW) -> write brief, stack, plan -> scripts/intake-done.sh
each step:    test first -> implement -> scripts/finish-step.sh S01 "feat: ..." "next action" ["gotcha"]
              (verify -> tick plan -> rewrite activeContext -> commit on ai/work)
long task:    scripts/finish-step.sh WIP ...  -> new task
```
Workflows (type in Cline): `/spec.md` `/plan.md` `/step.md` `/fix.md` `/review.md` `/init.md` (existing repo) `/handoff.md` `/mcp-check.md`.

## Gates (the scripts say no, the model has to fix it)
| Gate | Where | Refuses when |
|---|---|---|
| Placeholders | intake-done, finish-step | a memory file still has `{{...}}` |
| Plan sanity | intake-done | files column has class names instead of paths, or one file is in most steps |
| Decisions | intake-done, finish-step | no decision recorded; dependency manifest changed without a decision and `techContext.md` update |
| Scope | finish-step | the step changed files not listed in its plan line (code of later steps) |
| No work | finish-step | the step changed no project file (ticking steps one after another) |
| Test | finish-step | source changed without a test change (`refactor:`, `docs:`, `chore:` are exempt) |
| Structure | verify.sh | a source file over 250 lines, a test file over 300 |

Limits and modes (`fail` / `warn` / `off`) are in `scripts/gates.conf`; exceptions for the structure gate go to `.structure-ignore` (one `grep -E` pattern per line).

## Context compaction
Rules are re-sent with every request, so they survive auto-compact. The summary does not carry the project state reliably, so `00-core.md` tells the model to run BOOT again after any summary: read `activeContext.md`, `docs/plan.md`, `git status --short`. In Cline set Auto Compact to trigger early (around 55 to 65 percent of the window).

## Setup
1. Requirements: Git for Windows (Git Bash) or any bash, Python 3.12+, Node (for context7), `uv` (for Serena).
2. Set `git config user.name` / `user.email`.
3. MCP: copy a server list from `mcp/` into Cline's MCP settings (Windows: use the `windows` variant). Run `/mcp-check.md`.
4. Cline: Act mode for every workflow that writes files; auto-approve `bash scripts/*`.
5. Start with a plain prompt, for example: `Write full working flappy bird game`.

## Verify that memory works after a run
```
git log --stat -5     # every step commit must contain memory-bank/activeContext.md and docs/plan.md
head -n 8 memory-bank/activeContext.md
```
A final `attempt_completion` message must start with the `STEP DONE: ...` line copied from the script.
