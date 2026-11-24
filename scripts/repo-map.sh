#!/usr/bin/env bash
# Generates a compact map of the repo so the model can locate code without reading many files.
# Output is size-capped on purpose (context is expensive for a local model).
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
mkdir -p memory-bank
out=memory-bank/repo-map.md

{
  echo "# Repo map (generated $(date +%F); do not edit by hand)"
  echo
  echo "## Files"
  echo '```'
  files="$(git ls-files 2>/dev/null)"
  if [ -z "$files" ]; then
    # Fallback when git has no tracked files yet
    find . -maxdepth 3 -type f \
      ! -path '*/.*' ! -path '*/node_modules/*' ! -path '*/venv/*' ! -path '*/__pycache__/*' \
      | sed 's|^\./||' | head -n 300
  else
    echo "$files" | grep -Ev '(\.lock$|-lock\.|\.min\.|\.svg$|\.png$|\.jpe?g$|\.gif$|\.ico$|\.woff2?$)' | head -n 300
  fi
  echo '```'
  if command -v ctags >/dev/null 2>&1; then
    echo
    echo "## Symbols (file:line name kind)"
    echo '```'
    git ls-files 2>/dev/null | ctags -L - -x 2>/dev/null | awk '{print $4 ":" $3 " " $1 " " $2}' | head -n 400
    echo '```'
  else
    echo
    echo "_(install universal-ctags to include a symbol index)_"
  fi
} > "$out"

echo "wrote $out ($(wc -l < "$out") lines)"
