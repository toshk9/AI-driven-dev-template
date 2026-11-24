#!/usr/bin/env bash
# One-command quality gate. Must print "VERIFY OK" at the end, or "VERIFY FAILED".
# Autodetects common stacks. For anything custom, create scripts/verify.local.sh
# (it fully replaces the autodetection).
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

rc=0
run() {
  echo "> $*"
  "$@" 2>&1 | tail -n 60
  local s=${PIPESTATUS[0]}
  if [ "$s" -ne 0 ]; then echo "FAILED ($s): $*"; rc=1; fi
}

if [ -f scripts/verify.local.sh ]; then
  run bash scripts/verify.local.sh
else
  if [ -f package.json ]; then
    pm=npm
    [ -f pnpm-lock.yaml ] && pm=pnpm
    [ -f yarn.lock ] && pm=yarn
    # Safe JSON check for Windows bash
    has_script() {
      node -e "const p=require('./package.json'); process.exit((p.scripts && p.scripts['$1']) ? 0 : 1)" 2>/dev/null
    }
    has_script lint      && run "$pm" run lint
    has_script typecheck && run "$pm" run typecheck
    has_script test      && run "$pm" run test
  fi

  if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ] || [ -d .venv ]; then
    if ! bash scripts/py.sh -c "pass" >/dev/null 2>&1; then
      echo "NO VENV: run 'bash scripts/setup-env.sh python' first"
      rc=1
    else
      if bash scripts/py.sh -m ruff --version >/dev/null 2>&1; then
        run bash scripts/py.sh -m ruff check .
      else
        echo "warning: ruff is not installed in .venv, lint skipped"
      fi
      run bash scripts/py.sh -m pytest -q -x
    fi
  fi

  if [ -f go.mod ]; then
    run go vet ./...
    run go test ./...
  fi

  if [ -f Cargo.toml ]; then
    run cargo clippy -q
    run cargo test -q
  fi
fi

if [ "$rc" -eq 0 ]; then echo "VERIFY OK"; else echo "VERIFY FAILED"; fi
exit "$rc"
