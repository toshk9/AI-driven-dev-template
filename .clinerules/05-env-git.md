# Environment and git (enforced by scripts)

- Paths: forward slashes only, in files and commands (`src/pkg/app.py`; a backslash makes Git Bash create names like `srcpkg`). Create files with `write_to_file` (it creates parent folders); no `mkdir` just for that.
- Python: never bare `python`/`pip`/`pytest`/`ruff`; use `bash scripts/py.sh -m pytest tests/ -q`, `bash scripts/py.sh -m <pkg>`, `bash scripts/py.sh -m pip install <pkg>`. No `.venv` or `NO VENV`: `bash scripts/setup-env.sh python`. No global installs, no `--break-system-packages`.
- New package: user approval first; then update `pyproject.toml`/`requirements.txt`, `memory-bank/techContext.md` and `decide.sh` in the same step.
- Secrets: commit `.env.example` only, never `.env`. Docker/compose: read `.cline/skills/docker-deploy/SKILL.md` first.
- Git: never commit on main/master (scripts move you to `ai/work`); commit only through `intake-done.sh` / `finish-step.sh`, never `--no-verify` or `SKIP_VERIFY`. Message: `<type>: <S-id> <summary>`. Check `git status --short` before a step; leave user changes alone. No `push`, `reset --hard`, `clean`, `checkout -- .`, `--force` without approval.
