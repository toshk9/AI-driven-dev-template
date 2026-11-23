#!/usr/bin/env bash
# Generates a compact map of the repo for the AI model.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
mkdir -p memory-bank
out=memory-bank/repo-map.md

{
  echo "# Repo map (generated $(date +%F); do not edit by hand)"
  echo
  echo "## Files"
  echo '```'
  # Fallback to find if git ls-files returns empty
  files=$(git ls-files 2>/dev/null)
  if [ -z "$files" ]; then
    find . -maxdepth 3 -type f \
      ! -path '*/.*' ! -path '*/node_modules/*' ! -path '*/venv/*' ! -path '*/__pycache__/*' \
      | sed 's|^\./||' | head -n 300
  else
    echo "$files" \vert{} grep -Ev '(\.lock$|-lock\.|\.min\.|\.svg$\vert{}\.png$|\.jpe?g$\vert{}\.gif$|\.ico$\vert{}\.woff2?$)' | head -n 300
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
