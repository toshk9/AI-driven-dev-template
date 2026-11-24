# AI-driven dev template (Cline + local Qwen3.6-35B-A3B)

Project skeleton designed so a compact local model (Qwen3.6-35B-A3B-IQ3) works like a disciplined end-to-end engineer across Python services, Multi-Agent Systems (MAS), CLIs, Dockerized deployments, and GUI apps: adaptive intake, small vertical slices, unit + real integration/smoke tests, and script-enforced gates.

## How the memory works
| File | Written by | Read when |
|---|---|---|
| `memory-bank/activeContext.md` (`STATE: NEW` or `STATE: ACTIVE`) | `scripts/intake-done.sh`, `scripts/finish-step.sh` | FIRST tool call of every task & after compaction |
| `memory-bank/projectbrief.md`, `.clinerules/10-stack.md`, `docs/plan.md` | the model (`write_to_file`) at intake | `10-stack.md` auto-loaded; others at boot |
| `memory-bank/techContext.md` | the model, before first finish-step & on dep/entrypoint changes | when touching deps, entry points, or after compaction |
| `memory-bank/repo-map.md` | `scripts/repo-map.sh` (auto-run by `intake-done.sh` & `finish-step.sh`) | when locating files/symbols or after compaction |
| `docs/decisions.md` | `scripts/decide.sh` (at intake & on dep/architecture choices) | when choosing a library, layout, or contract |

Placeholders are `{{...}}`. Scripts refuse to continue while any remain.

## Flow
```
new project:  read activeContext (STATE: NEW) -> project-intake (+ /spec.md if M/L)
              -> write brief, stack, plan, decide.sh -> scripts/intake-done.sh
each step:    api-lookup (if new lib) -> test first -> implement -> verify.sh (includes smoke.sh)
              -> scripts/finish-step.sh S01 "feat: ..." "next action" ["gotcha"]
long task:    scripts/finish-step.sh WIP ... -> new task
```
Workflows: `/spec.md` `/plan.md` `/step.md` `/fix.md` `/review.md` `/init.md` `/handoff.md` `/mcp-check.md`.
Skills (loaded on demand): `project-intake`, `api-lookup`, `test-first`, `debug-loop`, `smoke-verify`, `docker-deploy`, `mas-architecture`.

## Gates (scripts fail loudly; the model must fix before continuing)
| Gate | Where | Refuses / warns when |
|---|---|---|
| Placeholders | `intake-done`, `finish-step` | memory files still contain `{{...}}` |
| Plan sanity | `intake-done` | steps lack real file paths, one file dominates most steps, or no smoke/e2e step |
| Decisions | `intake-done`, `finish-step` | no `D-n` decision recorded, or tracked manifest changed without `decide.sh` + `techContext.md` |
| Scope | `finish-step` | step modified files outside its `docs/plan.md` line |
| No work | `finish-step` | step changed no project files |
| Test | `finish-step` | source changed without a test change (`refactor:`, `docs:`, `chore:` exempt) |
| Structure & Hygiene | `check-structure.sh` | source > 250 lines, test > 300 lines, empty junk directories, or Dockerfile `:latest` / missing `USER` |
| Compile & Smoke | `verify.sh` | Python `compileall` fails, lint/tests fail, or `scripts/smoke.sh` fails |

Limits and modes (`fail` / `warn` / `off`) live in `scripts/gates.conf`; structure exceptions go in `.structure-ignore`.

## Context compaction
`.clinerules/*.md` are re-sent every turn, and `00-core.md` instructs the model to re-run BOOT (`activeContext.md`, `plan.md`, `decisions.md`, `repo-map.md`, `git status --short`) whenever context begins with a `SUMMARY`. In Cline, set Auto Compact around 55–65%.

## Setup
1. Requirements: Git for Windows (Git Bash) or POSIX bash, Python 3.12+, Node (`npx` for context7), `uv` (`uvx` for Serena).
2. Configure `git config user.name` and `user.email`.
3. MCP: copy a server list from `mcp/` into Cline's MCP settings (Windows: `cline_mcp_settings.windows.example.json`) and update `--project`. Run `/mcp-check.md`.
4. Cline: Act mode for coding workflows; auto-approve `bash scripts/*`.
5. Start with either a simple prompt (`"Сделай змейку на Python"`) or a detailed brief (`"Разработай сервис/MAS на Python по SOLID, с Docker..."`).
