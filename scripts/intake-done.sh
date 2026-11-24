#!/usr/bin/env bash
# Closes the INTAKE phase of a new project: checks memory files and plan sanity,
# creates git repo + .venv, sets memory-bank/activeContext.md to STATE: ACTIVE, commits, refreshes repo-map.
# Usage: bash scripts/intake-done.sh "<one-line goal>" [python]
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN_GATE=fail
[ -f scripts/gates.conf ] && . scripts/gates.conf

goal="${1:-}"; mode="${2:-auto}"
if [ -z "$goal" ]; then echo 'usage: bash scripts/intake-done.sh "<one-line goal>" [python]'; exit 2; fi

bad=0
for f in memory-bank/projectbrief.md .clinerules/10-stack.md docs/plan.md; do
  if [ ! -f "$f" ]; then
    echo "INTAKE NOT DONE: $f is missing. Create it with write_to_file."; bad=1
  elif grep -qF '{{' "$f"; then
    echo "INTAKE NOT DONE: $f still has {{...}} placeholders. Rewrite the WHOLE file with write_to_file using real content."; bad=1
  fi
done
if ! grep -Eq '^- \[ \] S[0-9]+' docs/plan.md 2>/dev/null; then
  echo "INTAKE NOT DONE: docs/plan.md has no step lines like '- [ ] S01 | goal | src/pkg/module.py, tests/test_module.py | test | AC-1'."; bad=1
fi
if ! grep -qE '^D-[0-9]+ \|' docs/decisions.md 2>/dev/null; then
  echo "INTAKE NOT DONE: docs/decisions.md has no decisions. Record the stack choice: bash scripts/decide.sh \"<decision>\" <stated|assumed> \"<reason>\""; bad=1
fi

# Plan sanity: the files column must hold real paths, and one file must not carry most of the plan.
if [ "$bad" -eq 0 ] && [ "$PLAN_GATE" != off ]; then
  verdict="$(awk -F'|' '
    /^- \[ \] S[0-9]+/ {
      n++; has = 0; split("", seen)
      k = split($3, a, ",")
      for (i = 1; i <= k; i++) {
        t = a[i]; gsub(/\([^)]*\)/, "", t); gsub(/[`'\''"]/, "", t); gsub(/^[ \t]+|[ \t]+$/, "", t)
        if (t ~ /[.\/]/ && !(t in seen)) { seen[t] = 1; cnt[t]++; has = 1 }
      }
      if (!has) nopath = nopath " " $1
    }
    END {
      if (nopath != "") print "NOPATH"
      for (t in cnt) if (n >= 4 && cnt[t] * 2 > n && t !~ /(^|\/)test/) print "HOT " t " " cnt[t] "/" n
    }' docs/plan.md)"
  if printf '%s\n' "$verdict" | grep -q '^NOPATH'; then
    msg="some steps have no file paths in the files column. Use real paths such as src/pkg/bird.py, never class names or '(Bird)'."
    if [ "$PLAN_GATE" = warn ]; then echo "WARNING: $msg"; else echo "INTAKE NOT DONE: $msg Rewrite docs/plan.md."; bad=1; fi
  fi
  hot="$(printf '%s\n' "$verdict" | grep '^HOT ' | head -n 1 || true)"
  if [ -n "$hot" ]; then
    msg="the file ${hot#HOT } is planned in most steps. That is a monolith. One module per responsibility (see .clinerules/12-architecture.md)."
    if [ "$PLAN_GATE" = warn ]; then echo "WARNING: $msg"; else echo "INTAKE NOT DONE: $msg Rewrite docs/plan.md with distinct files per step."; bad=1; fi
  fi
  step_count="$(grep -cE '^- \[ \] S[0-9]+' docs/plan.md 2>/dev/null || echo 0)"
  if [ "${step_count:-0}" -ge 3 ] && ! grep -qiE 'smoke|e2e|integration|entrypoint|end-to-end' docs/plan.md; then
    echo "WARNING: docs/plan.md does not mention a smoke/integration/e2e check. Consider adding scripts/smoke.sh in S01 and an end-to-end verification step at the end."
  fi
fi
[ "$bad" -eq 0 ] || exit 1

if [ "$mode" = auto ] && grep -qiE 'python|pytest' .clinerules/10-stack.md; then mode=python; fi
bash scripts/setup-env.sh "$mode" || { echo "INTAKE NOT DONE: setup-env.sh failed, see the error above."; exit 1; }

mkdir -p memory-bank
{
  echo "STATE: ACTIVE"
  echo "# Active context (rewritten by scripts/finish-step.sh; read it FIRST in every task)"
  echo
  echo "- Goal: $goal"
  echo "- Progress: 0/$(grep -cE '^- \[ \] ' docs/plan.md 2>/dev/null || echo 0) steps"
  echo "- Last finished: intake | $(date +%F)"
  echo "- Next plan step: $(grep -m1 -E '^- \[ \] ' docs/plan.md | cut -c1-200 | sed 's/^- \[ \] //')"
  echo "- Next action: do ONLY the next plan step, then run scripts/finish-step.sh"
  echo
  echo "## Gotchas"
} > memory-bank/activeContext.md

branch="$(git symbolic-ref --short -q HEAD || true)"
case "$branch" in
  main|master|"") git checkout -q -b ai/work 2>/dev/null || git checkout -q ai/work || { echo "INTAKE NOT DONE: cannot switch to branch ai/work"; exit 1; };;
esac
bash scripts/repo-map.sh >/dev/null 2>&1 || true
git add -A
if ! git diff --cached --quiet; then
  SKIP_VERIFY=1 git commit -q -m "docs: project intake (brief, stack, plan)" || { echo "INTAKE NOT DONE: git commit failed (set user.name and user.email?)"; exit 1; }
  echo "git: committed on $(git symbolic-ref --short HEAD): $(git log -1 --format='%h %s')"
fi
echo "INTAKE DONE. Memory is initialised (STATE: ACTIVE). Start step S01 now and do ONLY S01; finish every step with scripts/finish-step.sh."
