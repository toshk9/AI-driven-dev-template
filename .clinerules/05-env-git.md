# Environment and git (enforced by scripts)

## Paths & Shell (Windows + POSIX safe)
- Always use forward slashes `/` in file paths and bash commands (`src/pkg/app.py`, NEVER `src\pkg\app.py` — bash treats `\p` as an escape and creates broken names like `srcpkg`).
- Never run `mkdir` in bash just to create source folders; `write_to_file` creates parent directories automatically.

## Python
- Never run bare `python`, `python3`, `pip`, `pytest`, `ruff`. Always use the wrapper (uses `.venv`):
  - module: `bash scripts/py.sh -m <package>`   tests: `bash scripts/py.sh -m pytest tests/test_x.py -q`
  - install: `bash scripts/py.sh -m pip install <pkg>`   script: `bash scripts/py.sh path/to/script.py`
- Missing `.venv` or `NO VENV`: run `bash scripts/setup-env.sh python`. Safe to re-run.
- New packages require user approval. After installing, update `pyproject.toml` or `requirements.txt`, `memory-bank/techContext.md`, and `docs/decisions.md` (`decide.sh`) in the same step.
- Never use global Python, `sudo pip`, or `--break-system-packages`. Other stacks: use project-local toolchains, no global installs.

## Secrets & Containers
- Commit `.env.example` (variable names + safe placeholders), NEVER `.env` or real keys/tokens.
- Docker / compose changes: load `.cline/skills/docker-deploy/SKILL.md` before writing `Dockerfile` or `compose.yml`.

## Git
- Never commit on `main` or `master`; scripts move you to `ai/work`.
- Commit ONLY via `scripts/intake-done.sh` and `scripts/finish-step.sh`. Never use `--no-verify` or `SKIP_VERIFY`.
- Commit message: `<type>: <S-id> <imperative summary>` (`feat`, `fix`, `test`, `refactor`, `docs`, `chore`).
- Check `git status --short` before a step. Never touch user changes you did not make without asking.
- Never run `git push`, `git reset --hard`, `git clean`, `git checkout -- .`, or `--force` without explicit approval.
