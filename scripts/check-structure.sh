#!/usr/bin/env bash
# Structure gate: no giant source or test files. Called by verify.sh.
# Limits live in scripts/gates.conf. Exceptions: one grep -E pattern per line in .structure-ignore.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MAX_FILE_LINES=250; MAX_TEST_LINES=300; STRUCTURE_GATE=fail
[ -f scripts/gates.conf ] && . scripts/gates.conf
[ "$STRUCTURE_GATE" = off ] && exit 0

rc=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  case "$f" in
    *.py|*.js|*.jsx|*.ts|*.tsx|*.go|*.rs|*.java|*.kt|*.c|*.cc|*.cpp|*.h|*.hpp|*.cs|*.rb|*.php|*.swift|*.lua|*.gd) ;;
    *) continue;;
  esac
  case "$f" in scripts/*|.venv/*|venv/*|node_modules/*|vendor/*|dist/*|build/*|*.min.js|*.d.ts) continue;; esac
  if [ -f .structure-ignore ] && printf '%s\n' "$f" | grep -qE -f <(grep -vE '^[[:space:]]*(#|$)' .structure-ignore); then continue; fi
  n="$(wc -l < "$f" | tr -d ' ')"
  limit=$MAX_FILE_LINES
  case "$f" in tests/*|test/*|*/tests/*|*test_*|*_test.*|*.test.*|*.spec.*) limit=$MAX_TEST_LINES;; esac
  if [ "$n" -gt "$limit" ]; then
    echo "STRUCTURE: $f has $n lines (limit $limit). Split it by responsibility into several modules (see .clinerules/12-architecture.md), then run again."
    rc=1
  fi
done < <(git ls-files -co --exclude-standard 2>/dev/null)

if [ "$rc" -ne 0 ] && [ "$STRUCTURE_GATE" = warn ]; then echo "(STRUCTURE_GATE=warn: continuing)"; rc=0; fi
exit "$rc"
