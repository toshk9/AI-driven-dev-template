# Environment and git (the scripts enforce this)

## Python
- Never run bare `python`, `python3`, `pip`, `pytest`, `ruff`. The wrapper uses the project's `.venv`:
  - module: `bash scripts/py.sh -m <package>`   tests: `bash scripts/py.sh -m pytest tests/test_x.py -q`
  - install: `bash scripts/py.sh -m pip install <pkg>`   script: `bash scripts/py.sh path/to/script.py`
- "NO VENV" or missing `.venv`: run `bash scripts/setup-env.sh python`. Safe to repeat.
- A new package needs the user's approval. After installing, add it to `requirements.txt` or `pyproject.toml` in the same step, then update `memory-bank/techContext.md` (finish-step.sh checks this).
- Never use the global interpreter, `sudo pip`, or `--break-system-packages`. Other stacks: the project's own toolchain, no global installs.

## Git
- Never commit on `main` or `master`; the scripts move you to `ai/work`.
- Commit ONLY through `scripts/intake-done.sh` and `scripts/finish-step.sh`. Never `--no-verify`, never set `SKIP_VERIFY`.
- Commit message: `<type>: <S-id> <imperative summary>`. Types: feat, fix, test, refactor, docs, chore.
- Run `git status --short` before a step. Changes you did not make: ask the user, do not touch them.
- Never `git push`, `git reset --hard`, `git clean`, `git checkout -- .`, or anything with `--force` without explicit approval.
