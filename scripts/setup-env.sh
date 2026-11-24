#!/usr/bin/env bash
# Idempotent bootstrap: git repo + .gitignore + (Python) .venv + dev tools + pre-commit hook.
# Usage: bash scripts/setup-env.sh [python]      (no argument: Python is auto-detected from project files)
# Env: SKIP_DEV_TOOLS=1 skips installing pytest/ruff (offline use).
set -eu
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

mode="${1:-auto}"
if [ "$mode" = auto ]; then
  if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ] || [ -d .venv ]; then mode=python; fi
fi

# ---- git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -q -b main 2>/dev/null || { git init -q; git symbolic-ref HEAD refs/heads/main; }
  echo "git: initialized repo on branch main"
fi

# ---- .gitignore (append only what is missing)
touch .gitignore
for l in ".venv/" "__pycache__/" "*.pyc" ".pytest_cache/" ".ruff_cache/" ".env" "node_modules/" "memory-bank/repo-map.md"; do
  grep -qxF "$l" .gitignore || echo "$l" >> .gitignore
done

# ---- Python venv
if [ "$mode" = python ]; then
  if ! bash scripts/py.sh -c "pass" >/dev/null 2>&1; then
    if command -v python3 >/dev/null 2>&1; then python3 -m venv .venv
    elif command -v python >/dev/null 2>&1; then python -m venv .venv
    elif command -v py >/dev/null 2>&1; then py -3 -m venv .venv
    else echo "ERROR: no Python on PATH" >&2; exit 1; fi
    echo "venv: created .venv"
  else
    echo "venv: .venv already exists"
  fi
  bash scripts/py.sh -m pip install -q --upgrade pip >/dev/null 2>&1 || true
  if [ -f requirements.txt ]; then bash scripts/py.sh -m pip install -q -r requirements.txt; fi
  if [ -f requirements-dev.txt ]; then bash scripts/py.sh -m pip install -q -r requirements-dev.txt; fi
  if [ -f pyproject.toml ]; then
    bash scripts/py.sh -m pip install -q -e ".[dev]" >/dev/null 2>&1 || bash scripts/py.sh -m pip install -q -e . || true
  fi
  if [ "${SKIP_DEV_TOOLS:-0}" != 1 ]; then bash scripts/py.sh -m pip install -q pytest ruff; fi
  echo "venv: ready ($(bash scripts/py.sh --version))"
fi

# ---- first commit on main, so the repo has a HEAD (identity must be configured)
if ! git rev-parse --verify -q HEAD >/dev/null 2>&1; then
  if [ -n "$(git config user.email || true)" ] && [ -n "$(git config user.name || true)" ]; then
    git add -A
    git commit -q --no-verify -m "chore: bootstrap project tooling" && echo "git: initial commit created"
  else
    echo "git: set user.name and user.email (git config --global ...), then re-run this script" >&2
  fi
fi

# ---- pre-commit hook: manual commits are verified too
if [ -f .githooks/pre-commit ]; then
  chmod +x .githooks/pre-commit 2>/dev/null || true
  git config core.hooksPath .githooks
  echo "git: pre-commit hook enabled (runs scripts/verify.sh)"
fi
echo "SETUP OK"
