#!/usr/bin/env bash
# Generates a compact map of the repo so the model can locate files and symbols without reading many files.
# Output is size-capped on purpose (context is expensive for a local model).
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
mkdir -p memory-bank
out=memory-bank/repo-map.md

list_files() {
  local files
  files="$(git ls-files -co --exclude-standard 2>/dev/null || true)"
  if [ -z "$files" ]; then
    find . -maxdepth 4 -type f \
      ! -path '*/.git/*' ! -path '*/.venv/*' ! -path '*/venv/*' ! -path '*/node_modules/*' \
      ! -path '*/__pycache__/*' ! -path '*/*.egg-info/*' \
      | sed 's|^\./||' | sort | head -n 300
  else
    printf '%s\n' "$files" \
      | grep -Ev '(\.lock$|-lock\.|\.min\.|\.svg$|\.png$|\.jpe?g$|\.gif$|\.ico$|\.woff2?$|\.egg-info/|^(\.venv|venv|node_modules|__pycache__|dist|build)/)' \
      | sort | head -n 300
  fi
}

python_cmd() {
  if bash scripts/py.sh -c "pass" >/dev/null 2>&1; then
    echo "bash scripts/py.sh"
  elif command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1; then
    echo "python"
  fi
}

{
  echo "# Repo map (generated $(date +%F); do not edit by hand)"
  echo
  echo "## Files"
  echo '```'
  file_list="$(list_files)"
  printf '%s\n' "$file_list"
  echo '```'
  if command -v ctags >/dev/null 2>&1; then
    echo
    echo "## Symbols (file:line name kind)"
    echo '```'
    printf '%s\n' "$file_list" | ctags -L - -x 2>/dev/null | awk '{print $4 ":" $3 " " $1 " " $2}' | head -n 350
    echo '```'
  else
    pybin="$(python_cmd || true)"
    if [ -n "$pybin" ]; then
      echo
      echo "## Python Symbols (file:line kind signature)"
      echo '```'
      printf '%s\n' "$file_list" | grep -E '\.py$' | $pybin -c '
import ast, sys
count = 0
for raw in sys.stdin:
    path = raw.strip()
    if not path:
        continue
    try:
        with open(path, "r", encoding="utf-8") as fh:
            tree = ast.parse(fh.read(), filename=path)
    except Exception:
        continue
    sep = chr(44) + " "
    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            print(f"{path}:{node.lineno} class {node.name}")
            count += 1
            for sub in node.body:
                if isinstance(sub, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    sig = sep.join(a.arg for a in sub.args.args)
                    print(f"{path}:{sub.lineno}   def {node.name}.{sub.name}({sig})")
                    count += 1
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            sig = sep.join(a.arg for a in node.args.args)
            print(f"{path}:{node.lineno} def {node.name}({sig})")
            count += 1
        if count >= 350:
            break
    if count >= 350:
        break
' 2>/dev/null
      echo '```'
    else
      echo
      echo "_(install universal-ctags or Python to include a symbol index)_"
    fi
  fi
} > "$out"

echo "wrote $out ($(wc -l < "$out") lines)"
