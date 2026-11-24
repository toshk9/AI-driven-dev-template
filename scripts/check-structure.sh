#!/usr/bin/env bash
# Structure gate: file line limits, empty junk directories, and basic Dockerfile hygiene. Called by verify.sh.
# Limits live in scripts/gates.conf. Exceptions: one grep -E pattern per line in .structure-ignore.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MAX_FILE_LINES=250; MAX_TEST_LINES=300; STRUCTURE_GATE=fail; EMPTY_DIR_GATE=fail; DOCKER_GATE=warn
[ -f scripts/gates.conf ] && . scripts/gates.conf

rc=0
gate_issue() {
  local mode="$1" msg="$2"
  case "$mode" in
    off) return 0;;
    warn) echo "WARNING: $msg"; return 0;;
    *) echo "$msg"; rc=1;;
  esac
}

if [ "$STRUCTURE_GATE" != off ]; then
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    case "$f" in
      *.py|*.js|*.jsx|*.ts|*.tsx|*.go|*.rs|*.java|*.kt|*.c|*.cc|*.cpp|*.h|*.hpp|*.cs|*.rb|*.php|*.swift|*.lua|*.gd) ;;
      *) continue;;
    esac
    case "$f" in scripts/*|.venv/*|venv/*|node_modules/*|vendor/*|dist/*|build/*|*.egg-info/*|*.min.js|*.d.ts) continue;; esac
    if [ -f .structure-ignore ] && printf '%s\n' "$f" | grep -qE -f <(grep -vE '^[[:space:]]*(#|$)' .structure-ignore); then continue; fi
    n="$(wc -l < "$f" | tr -d ' ')"
    limit=$MAX_FILE_LINES
    case "$f" in tests/*|test/*|*/tests/*|*test_*|*_test.*|*.test.*|*.spec.*) limit=$MAX_TEST_LINES;; esac
    if [ "$n" -gt "$limit" ]; then
      gate_issue "$STRUCTURE_GATE" "STRUCTURE: $f has $n lines (limit $limit). Split it by responsibility into several modules (see .clinerules/12-architecture.md), then run again."
    fi
  done < <(git ls-files -co --exclude-standard 2>/dev/null)
fi

if [ "$EMPTY_DIR_GATE" != off ]; then
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    d="${d#./}"
    case "$d" in
      ""|.git|.git/*|.venv|.venv/*|venv|venv/*|node_modules|node_modules/*|__pycache__|*/__pycache__|*__pycache__/*|.pytest_cache|.pytest_cache/*|.ruff_cache|.ruff_cache/*|.mypy_cache|.mypy_cache/*|dist|dist/*|build|build/*|*.egg-info|*.egg-info/*) continue;;
    esac
    gate_issue "$EMPTY_DIR_GATE" "STRUCTURE: empty directory '$d' found (accidental mkdir or backslash path?). Remove it or add real files, then run again."
  done < <(find . -maxdepth 4 -type d -empty 2>/dev/null)
fi

if [ "$DOCKER_GATE" != off ] && [ -f Dockerfile ]; then
  if grep -qE '^[[:space:]]*FROM[[:space:]]+[^[:space:]]+:latest([[:space:]]|$)' Dockerfile; then
    gate_issue "$DOCKER_GATE" "DOCKER: Dockerfile uses ':latest' base tag. Pin an explicit version tag (e.g. python:3.12-slim)."
  fi
  if ! grep -qE '^[[:space:]]*USER[[:space:]]+' Dockerfile; then
    gate_issue "$DOCKER_GATE" "DOCKER: Dockerfile has no non-root USER instruction."
  fi
fi

exit "$rc"
