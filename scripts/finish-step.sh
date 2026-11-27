#!/usr/bin/env bash
# The ONLY way to finish a unit of work. One command:
#   memory gates -> scope/test gates -> verify -> tick plan -> rewrite activeContext -> commit -> repo-map.
# Usage: bash scripts/finish-step.sh <STEP_ID|FIX|WIP> "<type: summary>" "<next action>" ["<gotcha>"]
#   STEP_ID  a step id from docs/plan.md, e.g. S03
#   FIX      a bug fix outside the plan
#   WIP      save state without any gate (long task, context running out, handoff)
# Example: bash scripts/finish-step.sh S03 "feat: S03 pipes spawn" "add collision test" "pygame needs SDL_VIDEODRIVER=dummy in tests"
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCOPE_GATE=fail; TEST_GATE=fail
[ -f scripts/gates.conf ] && . scripts/gates.conf

id="${1:-}"; msg="${2:-}"; next="${3:-}"; gotcha="${4:-}"
fail() { echo "STEP NOT DONE: $*"; exit 1; }
gate() { case "$1" in off) return 0;; warn) echo "WARNING: $2"; return 0;; *) fail "$2";; esac; }

if [ -z "$id" ] || [ -z "$msg" ] || [ -z "$next" ]; then
  echo 'usage: bash scripts/finish-step.sh <STEP_ID|FIX|WIP> "<type: summary>" "<next action>" ["<gotcha>"]'
  exit 2
fi
case "$id" in *[!A-Za-z0-9_-]*) fail "bad step id '$id' (letters, digits, - and _ only)";; esac
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not a git repo. Run: bash scripts/setup-env.sh"

plan=docs/plan.md
ctx=memory-bank/activeContext.md

if [ "$id" != WIP ]; then
  # ---------- 1. memory gates
  for f in memory-bank/projectbrief.md .clinerules/10-stack.md "$plan" memory-bank/techContext.md; do
    if [ ! -f "$f" ] || grep -qF '{{' "$f"; then
      fail "$f is missing or still a template ({{...}}). Rewrite the WHOLE file with write_to_file using real content, then run this command again."
    fi
  done
  changed="$(git status --porcelain -uall | sed -E 's/^.{3}//; s/.* -> //')"
  changed_manifests="$(printf '%s\n' "$changed" | grep -E '(^|/)(requirements[^/]*\.txt|pyproject\.toml|package\.json|go\.mod|Cargo\.toml)$' || true)"
  if [ -n "$changed_manifests" ]; then
    printf '%s\n' "$changed" | grep -qx 'memory-bank/techContext.md' ||
      fail "a dependency manifest changed but memory-bank/techContext.md did not. Rewrite techContext.md with write_to_file (stack, entry points, dependencies, max 30 lines), then run this command again."
    need_decide=0
    if ! grep -qE '^D-[0-9]+ \|' docs/decisions.md 2>/dev/null; then
      need_decide=1
    else
      while IFS= read -r mf; do
        [ -n "$mf" ] || continue
        if git ls-files --error-unmatch "$mf" >/dev/null 2>&1; then need_decide=1; fi
      done <<< "$changed_manifests"
    fi
    if [ "$need_decide" = 1 ]; then
      printf '%s\n' "$changed" | grep -qx 'docs/decisions.md' ||
        fail "an existing dependency manifest changed (or no decisions recorded) without updating docs/decisions.md. Record why: bash scripts/decide.sh \"add <package>\" <stated|assumed> \"<reason>\", then run this command again."
    fi
  fi

  # ---------- 2. step line and its allowed files
  allowed=""
  if [ "$id" != FIX ]; then
    line="$(grep -E "^- \[[ x]\] ${id}( |\|)" "$plan" | head -n 1 || true)"
    if [ -z "$line" ]; then
      fail "step '$id' is not in $plan. Unchecked steps: $(grep -oE '^- \[ \] S[0-9]+' "$plan" | sed 's/- \[ \] //' | tr '\n' ' ')"
    fi
    allowed="$(printf '%s\n' "$line" | awk -F'|' '{print $3}' | tr ',' '\n' | sed -E 's/\([^)]*\)//g; s/[`"'\'']//g; s/^[[:space:]]+//; s/[[:space:]]+$//' | grep -E '[./]' || true)"
  fi

  # ---------- 3. what did this step actually change?
  work=""; offenders=""; srcchanged=0; testchanged=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in memory-bank/*|docs/plan.md|docs/decisions.md|.gitignore) continue;; esac
    work="$work $f"
    [ -e "$f" ] || continue   # a deleted file (cleanup) counts as work but never as scope creep
    is_test=0; is_code=0
    case "$f" in tests/*|test/*|*/tests/*|*test_*|*_test.*|*.test.*|*.spec.*|conftest.py|*/conftest.py) is_test=1;; esac
    case "$f" in *.py|*.js|*.jsx|*.ts|*.tsx|*.go|*.rs|*.java|*.kt|*.c|*.cc|*.cpp|*.h|*.hpp|*.cs|*.rb|*.php|*.swift|*.lua|*.gd) is_code=1;; esac
    [ "$is_test" = 1 ] && testchanged=1
    [ "$is_code" = 1 ] && [ "$is_test" = 0 ] && srcchanged=1
    case "$f" in
      *.md|docs/*|.clinerules/*|.vscode/*|requirements*.txt|pyproject.toml|package.json|package-lock.json|pnpm-lock.yaml|yarn.lock|go.mod|go.sum|Cargo.toml|Cargo.lock|__init__.py|*/__init__.py|conftest.py|*/conftest.py|pytest.ini|setup.cfg|ruff.toml|.ruff.toml|mypy.ini|.editorconfig|.env.example|scripts/verify.local.sh|scripts/smoke.sh|scripts/gates.conf|.structure-ignore) continue;;
    esac
    [ -z "$allowed" ] && continue
    base="${f##*/}"; stem="${base%.*}"; tstem="${stem#test_}"; tstem="${tstem%_test}"; tstem="${tstem%.test}"; tstem="${tstem%.spec}"
    in_scope=0
    for tok in $allowed; do
      case "$tok" in
        */) case "$f" in "$tok"*|*"/$tok"*) in_scope=1;; esac;;
        *)  [ "$f" = "$tok" ] && in_scope=1
            case "$f" in *"/$tok") in_scope=1;; esac
            if [ "$is_test" = 1 ]; then tb="${tok##*/}"; [ "${tb%.*}" = "$tstem" ] && in_scope=1; fi;;
      esac
    done
    [ "$in_scope" = 1 ] || offenders="$offenders $f"
  done <<< "$changed"

  [ -n "$work" ] || fail "no project file changed in this step. Do the work of $id first. Never tick a step you did not do."
  if [ -n "$offenders" ]; then
    gate "$SCOPE_GATE" "these files do not belong to step $id:$offenders. Step $id lists: $(printf '%s ' $allowed | sed 's/ $//'). Do ONLY the current step: undo the extra changes (code of later steps must not be written now), or, if a file truly belongs here, add it to the files column of $id in docs/plan.md and run this command again."
  fi
  case "$msg" in
    refactor:*|docs:*|chore:*) : ;;
    *) if [ "$srcchanged" = 1 ] && [ "$testchanged" = 0 ]; then
         gate "$TEST_GATE" "source code changed but no test file changed. Write or extend a test first, then run this command again."
       fi;;
  esac

  # ---------- 4. verify
  bash scripts/verify.sh || fail "verify failed. Fix the cause (see debug-loop), then run this command again."

  # ---------- 5. tick the plan
  if [ "$id" != FIX ]; then
    sed -E "s/^- \[ \] (${id})( |\|)/- [x] \1\2/" "$plan" > "$plan.tmp" && mv "$plan.tmp" "$plan"
    echo "plan: $id ticked"
  fi
fi

# ---------- 6. activeContext (script-owned; keeps Goal, recent commits, and last 8 gotchas)
mkdir -p memory-bank
goal="$(grep -m1 '^- Goal:' "$ctx" 2>/dev/null || true)"
old="$(sed -n '/^## Gotchas/,$p' "$ctx" 2>/dev/null | tail -n +2 | grep -v '^[[:space:]]*$' || true)"
nextstep="$(grep -m1 -E '^- \[ \] ' "$plan" 2>/dev/null | cut -c1-200 || true)"
done_cnt="$(grep -cE '^- \[x\] ' "$plan" 2>/dev/null || true)"
rem_cnt="$(grep -cE '^- \[ \] ' "$plan" 2>/dev/null || true)"
tot_cnt=$(( ${done_cnt:-0} + ${rem_cnt:-0} ))
recent_commits="$(git log -n 3 --oneline 2>/dev/null || true)"
{
  echo "STATE: ACTIVE"
  echo "# Active context (rewritten by scripts/finish-step.sh; read it FIRST in every task)"
  echo
  echo "${goal:-- Goal: (see memory-bank/projectbrief.md)}"
  echo "- Progress: ${done_cnt:-0}/${tot_cnt} steps"
  echo "- Last finished: $id | $msg | $(date +%F)"
  echo "- Next plan step: $(printf %s "${nextstep:-none (plan complete)}" | sed 's/^- \[ \] //')"
  echo "- Next action: $next"
  if [ -n "$recent_commits" ]; then
    echo
    echo "## Recent commits"
    printf '%s\n' "$recent_commits" | sed 's/^/- /'
  fi
  echo
  echo "## Gotchas"
  { [ -n "$old" ] && printf '%s\n' "$old"; [ -n "$gotcha" ] && echo "- $gotcha"; } | tail -n 8
} > "$ctx.tmp" && mv "$ctx.tmp" "$ctx"
echo "memory: activeContext.md rewritten"

# ---------- 7. git (never on main/master)
branch="$(git symbolic-ref --short -q HEAD || true)"
case "$branch" in
  main|master|"") git checkout -q -b ai/work 2>/dev/null || git checkout -q ai/work || fail "cannot switch to branch ai/work";;
esac
bash scripts/repo-map.sh >/dev/null 2>&1 || true
git add -A
if git diff --cached --quiet; then
  echo "git: nothing to commit"
else
  SKIP_VERIFY=1 git commit -q -m "$msg" || fail "git commit failed (set user.name and user.email?)"
  echo "git: committed on $(git symbolic-ref --short HEAD): $(git log -1 --format='%h %s')"
fi

if [ "$id" = WIP ]; then echo "WIP SAVED: state is in memory-bank/activeContext.md. Open a new task and continue."; exit 0; fi
echo "STEP DONE: $id"
if [ "${rem_cnt:-0}" -eq 0 ]; then
  if [ ! -f scripts/smoke.sh ] && [ -d src ]; then
    echo "NOTE: no scripts/smoke.sh found. Confirm the real entrypoint runs cleanly end-to-end before calling attempt_completion."
  fi
  echo "PLAN COMPLETE: every step is done. Confirm all acceptance criteria and smoke checks pass, then call attempt_completion (first line = STEP DONE: $id; last line tells the user: Optional final audit: set reasoning effort to maximum and Max Output Tokens to 16000, then type /audit.md)."
else
  echo "REMAINING: $rem_cnt step(s). NEXT: $nextstep"
  echo "Do ONLY that step next (its listed files, its test). Continue unless the user asked for a single step."
fi
