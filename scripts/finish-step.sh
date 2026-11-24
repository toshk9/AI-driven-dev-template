#!/usr/bin/env bash
# The ONLY way to finish a unit of work. One command: memory gates -> verify -> tick plan -> rewrite activeContext -> commit.
# Usage: bash scripts/finish-step.sh <STEP_ID|FIX|WIP> "<type: summary>" "<next action>" ["<gotcha>"]
#   STEP_ID  a step id from docs/plan.md, e.g. S03
#   FIX      a bug fix outside the plan
#   WIP      save state without verify (long task, context running out, handoff)
# Example: bash scripts/finish-step.sh S03 "feat: S03 pipes spawn" "add collision test" "pygame needs SDL_VIDEODRIVER=dummy in tests"
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

id="${1:-}"; msg="${2:-}"; next="${3:-}"; gotcha="${4:-}"
fail() { echo "STEP NOT DONE: $*"; exit 1; }

if [ -z "$id" ] || [ -z "$msg" ] || [ -z "$next" ]; then
  echo 'usage: bash scripts/finish-step.sh <STEP_ID|FIX|WIP> "<type: summary>" "<next action>" ["<gotcha>"]'
  exit 2
fi
case "$id" in *[!A-Za-z0-9_-]*) fail "bad step id '$id' (letters, digits, - and _ only)";; esac
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not a git repo. Run: bash scripts/setup-env.sh"

plan=docs/plan.md
ctx=memory-bank/activeContext.md

# ---------- 1. memory gates (fast feedback first)
if [ "$id" != WIP ]; then
  for f in memory-bank/projectbrief.md .clinerules/10-stack.md "$plan" memory-bank/techContext.md; do
    if [ ! -f "$f" ] || grep -qF '{{' "$f"; then
      fail "$f is missing or still a template ({{...}}). Rewrite the WHOLE file with write_to_file using real content, then run this command again."
    fi
  done
  changed="$(git status --porcelain -uall | sed -E 's/^.{3}//; s/.* -> //')"
  if printf '%s\n' "$changed" | grep -Eq '(^|/)(requirements[^/]*\.txt|pyproject\.toml|package\.json|go\.mod|Cargo\.toml)$'; then
    printf '%s\n' "$changed" | grep -qx 'memory-bank/techContext.md' ||
      fail "a dependency manifest changed but memory-bank/techContext.md did not. Rewrite techContext.md with write_to_file (stack, entry points, dependencies, max 30 lines), then run this command again."
  fi
  case "$id" in
    FIX) : ;;
    *)
      if ! grep -Eq "^- \[[ x]\] ${id}( |\|)" "$plan"; then
        fail "step '$id' is not in $plan. Unchecked steps: $(grep -oE '^- \[ \] S[0-9]+' "$plan" | sed 's/- \[ \] //' | tr '\n' ' ')"
      fi;;
  esac

  # ---------- 2. verify
  bash scripts/verify.sh || fail "verify failed. Fix the cause (see debug-loop), then run this command again."

  # ---------- 3. tick the plan
  if [ "$id" != FIX ]; then
    sed -E "s/^- \[ \] (${id})( |\|)/- [x] \1\2/" "$plan" > "$plan.tmp" && mv "$plan.tmp" "$plan"
    echo "plan: $id ticked"
  fi
fi

# ---------- 4. activeContext (script-owned; keeps Goal and the last 8 gotchas)
mkdir -p memory-bank
goal="$(grep -m1 '^- Goal:' "$ctx" 2>/dev/null || true)"
old="$(sed -n '/^## Gotchas/,$p' "$ctx" 2>/dev/null | tail -n +2 | grep -v '^[[:space:]]*$' || true)"
nextstep="$(grep -m1 -E '^- \[ \] ' "$plan" 2>/dev/null | cut -c1-200 || true)"
remaining="$(grep -cE '^- \[ \] ' "$plan" 2>/dev/null || true)"
{
  echo "STATE: ACTIVE"
  echo "# Active context (rewritten by scripts/finish-step.sh; read it FIRST in every task)"
  echo
  echo "${goal:-- Goal: (see memory-bank/projectbrief.md)}"
  echo "- Last finished: $id | $msg | $(date +%F)"
  echo "- Next plan step: $(printf %s "${nextstep:-none (plan complete)}" | sed "s/^- \[ \] //")"
  echo "- Next action: $next"
  echo
  echo "## Gotchas"
  { [ -n "$old" ] && printf '%s\n' "$old"; [ -n "$gotcha" ] && echo "- $gotcha"; } | tail -n 8
} > "$ctx.tmp" && mv "$ctx.tmp" "$ctx"
echo "memory: activeContext.md rewritten"

# ---------- 5. git (never on main/master)
branch="$(git symbolic-ref --short -q HEAD || true)"
case "$branch" in
  main|master|"") git checkout -q -b ai/work 2>/dev/null || git checkout -q ai/work || fail "cannot switch to branch ai/work";;
esac
git add -A
if git diff --cached --quiet; then
  echo "git: nothing to commit"
else
  SKIP_VERIFY=1 git commit -q -m "$msg" || fail "git commit failed (set user.name and user.email?)"
  echo "git: committed on $(git symbolic-ref --short HEAD): $(git log -1 --format='%h %s')"
fi

if [ "$id" = WIP ]; then echo "WIP SAVED: state is in memory-bank/activeContext.md. Open a new task and continue."; exit 0; fi
echo "STEP DONE: $id"
if [ "${remaining:-0}" -eq 0 ]; then
  echo "PLAN COMPLETE: every step is done. Now call attempt_completion; its first line must be the STEP DONE line above."
else
  echo "REMAINING: $remaining step(s). NEXT: $nextstep"
  echo "Continue with that step now unless the user asked for a single step."
fi
