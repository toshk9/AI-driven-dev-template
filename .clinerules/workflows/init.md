# /init.md — bootstrap this project for AI-assisted work

Do these in order. One tool call per message.

1. `list_files` at the repo root (non-recursive). Read manifests that exist: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `README.md`.
2. Fill `.clinerules/10-stack.md` with the REAL commands you found. Do not guess; if unsure, write `UNKNOWN` and ask the user.
3. Run `bash scripts/verify.sh`. If it cannot work for this stack (custom build, monorepo), create `scripts/verify.local.sh` with the correct gate commands; `verify.sh` will run it instead.
4. Run `bash scripts/repo-map.sh` to generate `memory-bank/repo-map.md`.
5. Fill `memory-bank/projectbrief.md` and `memory-bank/techContext.md` (max 30 lines each, facts only).
6. Reply (max 6 lines): detected stack, verify status (OK / failing + why), what the user must decide.
