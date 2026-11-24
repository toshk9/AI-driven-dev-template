#!/usr/bin/env bash
# Closes the INTAKE phase of a new project: checks the memory files are really filled,
# creates git repo + .venv, flips memory-bank/activeContext.md to STATE: ACTIVE, commits.
# Usage: bash scripts/intake-done.sh "<one-line goal>" [python]
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

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
  echo "INTAKE NOT DONE: docs/plan.md has no step lines like '- [ ] S01 | goal | files | test | AC-1'."; bad=1
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
  echo "- Last finished: intake | $(date +%F)"
  echo "- Next plan step: $(grep -m1 -E '^- \[ \] ' docs/plan.md | cut -c1-200 | sed 's/^- \[ \] //')"
  echo "- Next action: do the next plan step, then run scripts/finish-step.sh"
  echo
  echo "## Gotchas"
} > memory-bank/activeContext.md

branch="$(git symbolic-ref --short -q HEAD || true)"
case "$branch" in
  main|master|"") git checkout -q -b ai/work 2>/dev/null || git checkout -q ai/work || { echo "INTAKE NOT DONE: cannot switch to branch ai/work"; exit 1; };;
esac
git add -A
if ! git diff --cached --quiet; then
  SKIP_VERIFY=1 git commit -q -m "docs: project intake (brief, stack, plan)" || { echo "INTAKE NOT DONE: git commit failed (set user.name and user.email?)"; exit 1; }
  echo "git: committed on $(git symbolic-ref --short HEAD): $(git log -1 --format='%h %s')"
fi
echo "INTAKE DONE. Memory is initialised (STATE: ACTIVE). Start step S01 now; finish every step with scripts/finish-step.sh."
