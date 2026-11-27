# AI-driven dev template (Cline + local Qwen3.6-35B-A3B)

Project skeleton designed so a compact local model (Qwen3.6-35B-A3B, IQ4_XS / Q4_K_M) works like a disciplined end-to-end engineer across Python services, Multi-Agent Systems (MAS), CLIs, Dockerized deployments, and GUI apps: adaptive intake, small vertical slices, unit + real integration/smoke tests, and script-enforced gates.

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
Workflows: `/spec.md` `/plan.md` `/step.md` `/fix.md` `/review.md` `/audit.md` (final deep audit) `/init.md` `/handoff.md` `/mcp-check.md`.
Skills (loaded on demand): `project-intake`, `api-lookup`, `debug-loop`, `smoke-verify`, `docker-deploy`, `mas-architecture`.

## Final audit (after PLAN COMPLETE)
The loop runs at low reasoning effort for speed. The audit is the one place for maximum effort: in Cline set reasoning effort to maximum and Max Output Tokens to 16000 or more (thinking counts against the output limit and a cut-off ends in a broken tool call), then type `/audit.md`. `scripts/audit.sh` keeps the ledger `docs/audit.md`: every module must be marked reviewed, every BUG or RISK needs a concrete failure scenario, a failing test and a fix (or a reasoned rejection), and one end-to-end flow must be traced. `audit.sh done` refuses otherwise. Time: roughly 3 to 6 minutes per module at 28 t/s.

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
`.clinerules/*.md` are re-sent every turn, so rules survive. The chat history does not: for a local llama.cpp model Cline most likely falls back to plain truncation of old messages (its docs describe summarisation only for supported models), so the model may not notice the loss. Project state therefore lives in files, and `00-core.md` re-runs BOOT (`activeContext.md`) at the start of every task and after any summary or "history removed" notice. Cline documents no compaction threshold; watch the context meter and keep llama.cpp `-c` and Cline's "Context Window Size" in sync (Cline value about 4k lower).

## Speed on a local model (8 GB VRAM + 24 GB RAM)
Time per task is roughly (number of tool calls) x (thinking + output tokens / 30 t/s + prompt re-processing). In order of impact:
1. Thinking: every tool call is one full model turn. Run the act loop with thinking off (`--chat-template-kwargs '{"enable_thinking":false}'`, in PowerShell `"{\"enable_thinking\":false}"`) and set Cline's reasoning effort to none/low. The gates (tests, verify, smoke) catch mistakes that thinking would otherwise try to prevent.
2. Prompt re-processing: Qwen3.6 is a hybrid (DeltaNet + attention) model, so llama.cpp can only resume from context checkpoints. If no checkpoint covers the prefix it re-reads the whole prompt every turn. Run once with `-lv 4` and search the log for `forcing full prompt re-processing due to lack of cache data`; also compare tokens in `prompt eval time` per request with the full context size.
3. Window: use `-c 65536` (KV cache at q8_0 is about 0.7 GB; 32k leaves little after Cline's own prompt and the MCP tool lists, which forces constant truncation and re-processing).
4. MCP tool lists are part of every prompt: the example configs start Serena with `--add-mode no-memories`. After changing them run `/mcp-check.md` and confirm `write_memory` is gone.
Starting flags: `llama-server -m <Q4_K_M or IQ4_XS>.gguf --jinja -ngl 99 --n-cpu-moe 32 -fa on -c 65536 --cache-type-k q8_0 --cache-type-v q8_0 -np 1 -b 2048 -ub 1024 --ctx-checkpoints 12 --checkpoint-min-step 1024 --cache-ram 2048` (confirm flag names with `llama-server --help`; they change between builds; lower `--n-cpu-moe` until VRAM is about 7.2 GB).

## Setup
1. Requirements: Git for Windows (Git Bash) or POSIX bash, Python 3.12+, Node (`npx` for context7), `uv` (`uvx` for Serena).
2. Configure `git config user.name` and `user.email`.
3. MCP: copy a server list from `mcp/` into Cline's MCP settings (Windows: `cline_mcp_settings.windows.example.json`) and update `--project`. Run `/mcp-check.md`.
4. Cline: Act mode for coding workflows; auto-approve `bash scripts/*`.
5. Start with either a simple prompt (`"Сделай змейку на Python"`) or a detailed brief (`"Разработай сервис/MAS на Python по SOLID, с Docker..."`).
