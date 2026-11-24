#!/usr/bin/env bash
# Appends one numbered line to docs/decisions.md.
# Usage: bash scripts/decide.sh "<decision>" <stated|assumed> "<reason>"
# Example: bash scripts/decide.sh "Python 3.12 + pygame, src/ layout" assumed "user gave no stack; most common for 2D games"
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
d="${1:-}"; kind="${2:-}"; reason="${3:-}"
if [ -z "$d" ] || [ -z "$reason" ] || { [ "$kind" != stated ] && [ "$kind" != assumed ]; }; then
  echo 'usage: bash scripts/decide.sh "<decision>" <stated|assumed> "<reason>"'
  exit 2
fi
f=docs/decisions.md
mkdir -p docs
[ -f "$f" ] || echo "# Decisions log" > "$f"
n="$(grep -cE '^D-[0-9]+ \|' "$f" || true)"; n=$((n + 1))
d="${d//|/-}"; reason="${reason//|/-}"
echo "D-$n | $d | $kind | $reason" >> "$f"
echo "decision D-$n recorded in $f"
