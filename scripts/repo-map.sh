#!/usr/bin/env bash
# Compact map of the PROJECT (not of the harness) so the model can locate files and symbols in ONE read.
# One line per file, public symbols only, hard size cap (context is expensive for a local model).
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
mkdir -p memory-bank
out=memory-bank/repo-map.md
MAX_FILES=80; MAX_SYMBOL_FILES=60

# Harness files are not part of the project: skip them.
SKIP='^(\.clinerules|\.cline|\.vscode|\.githooks|mcp|memory-bank)/|^scripts/(check-structure\.sh|decide\.sh|finish-step\.sh|gates\.conf|intake-done\.sh|py\.sh|repo-map\.sh|setup-env\.sh|verify\.sh|verify\.local\.sh)$|^docs/(decisions|plan)\.md$|^\.(gitignore|gitattributes|clineignore|structure-ignore|editorconfig)$|\.lock$|-lock\.|\.min\.|\.(svg|png|jpe?g|gif|ico|woff2?|wav|mp3|ogg|ttf)$|(^|/)(\.venv|venv|node_modules|__pycache__|dist|build|[^/]*\.egg-info)/'

files="$( { git ls-files -co --exclude-standard 2>/dev/null || find . -maxdepth 4 -type f | sed 's|^\./||'; } | grep -Ev "$SKIP" | sort )"

python_cmd() {
  for c in "bash scripts/py.sh" python3 python; do
    $c -c "pass" >/dev/null 2>&1 && { echo "$c"; return; }
  done
}

{
  echo "# Repo map (generated $(date +%F); do not edit by hand; project files only)"
  echo
  echo "## Files (lines)"
  echo '```'
  n=0
  printf '%s\n' "$files" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ -f "$f" ] || continue
    n=$((n+1)); [ "$n" -gt "$MAX_FILES" ] && { echo "... more files (use list_files)"; break; }
    echo "$f ($(wc -l < "$f" | tr -d ' '))"
  done
  echo '```'
  echo
  echo "## Public symbols (one line per file)"
  echo '```'
  pybin="$(python_cmd || true)"
  if [ -n "$pybin" ]; then
    printf '%s\n' "$files" | grep -E '\.py$' | grep -Ev '(^|/)__init__\.py$' | $pybin -c '
import ast, sys
MAXF = int(sys.argv[1]); shown = 0
for raw in sys.stdin:
    path = raw.strip()
    if not path:
        continue
    try:
        tree = ast.parse(open(path, encoding="utf-8").read(), filename=path)
    except Exception:
        continue
    parts = []
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and not node.name.startswith("_"):
            ms = [s.name for s in node.body
                  if isinstance(s, (ast.FunctionDef, ast.AsyncFunctionDef)) and not s.name.startswith("_")]
            parts.append("class %s(%s)" % (node.name, ", ".join(ms)) if ms else "class %s" % node.name)
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and not node.name.startswith("_"):
            parts.append("def %s" % node.name)
    if not parts:
        continue
    if "/tests/" in "/" + path or path.startswith("tests/"):
        parts = [p for p in parts if p.startswith("class")] or ["%d test functions" % sum(1 for p in parts if p.startswith("def"))]
    shown += 1
    if shown > MAXF:
        print("... more files (use get_symbols_overview)")
        break
    print((path + ": " + "; ".join(parts))[:240])
' "$MAX_SYMBOL_FILES" 2>/dev/null
  fi
  if command -v ctags >/dev/null 2>&1; then
    printf '%s\n' "$files" | grep -Ev '\.py$' | ctags -L - -x --kinds-all='*' 2>/dev/null \
      | awk '$2=="function"||$2=="class"||$2=="method"||$2=="interface"{a[$4]=a[$4] (a[$4]?", ":"") $1} END{for(f in a) print substr(f ": " a[f],1,240)}' | sort | head -n 40
  fi
  echo '```'
} > "$out"

echo "wrote $out ($(wc -l < "$out") lines)"
