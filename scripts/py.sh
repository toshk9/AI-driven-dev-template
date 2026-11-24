#!/usr/bin/env bash
# Runs Python from the project's virtualenv, so nobody has to remember to activate it.
# Usage: bash scripts/py.sh -m pytest -q        bash scripts/py.sh -m pip install <pkg>
set -eu
# No stale .pyc: a file rewritten within the same second with the same size would otherwise run old code.
export PYTHONDONTWRITEBYTECODE=1
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
for p in "$root/.venv/Scripts/python.exe" "$root/.venv/bin/python"; do
  if [ -x "$p" ]; then exec "$p" "$@"; fi
done
echo "NO VENV: run 'bash scripts/setup-env.sh python' first." >&2
exit 127
