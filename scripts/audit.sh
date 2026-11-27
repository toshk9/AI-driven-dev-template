#!/usr/bin/env bash
# Final audit ledger (script-owned file docs/audit.md). Used by the /audit.md workflow AFTER the plan is complete.
#   audit.sh start                         preconditions (plan done, VERIFY OK, clean tree) + module list
#   audit.sh seen <path> ["note"]          mark one module as fully reviewed
#   audit.sh add <path> <BUG|RISK|NIT> "<what is wrong>" "<concrete failure: input -> wrong result>"
#   audit.sh flow "<name>" "<trace and result>"   record one end-to-end flow you traced step by step
#   audit.sh resolve <F-n> <fixed|rejected> "<evidence or reason>"
#   audit.sh status                        what is still open
#   audit.sh done                          final gate: prints AUDIT DONE or AUDIT NOT DONE
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
A=docs/audit.md; ctx=memory-bank/activeContext.md
fail() { echo "AUDIT NOT DONE: $*"; exit 1; }
clean() { printf '%s' "$1" | tr '\n|&' '  /' | cut -c1-400; }
set_next() {  # keep activeContext pointing at the audit
  [ -f "$ctx" ] || return 0
  awk -v n="- Next action: $1" '/^- Next action:/{print n; next} {print}' "$ctx" > "$ctx.tmp" && mv "$ctx.tmp" "$ctx"
}
modules() {
  git ls-files -co --exclude-standard 2>/dev/null \
    | grep -E '\.(py|js|jsx|ts|tsx|go|rs|java|kt|c|cc|cpp|h|hpp|cs|rb|php|swift|lua|gd)$' \
    | grep -Ev '(^|/)(tests?|__tests__)/|(^|/)(test_[^/]*|[^/]*_test\.[^/]*|[^/]*\.(test|spec)\.[^/]*|conftest\.py|__init__\.py)$' \
    | grep -Ev '^(\.clinerules|\.cline|\.vscode|\.githooks|mcp|memory-bank)/' | sort
}
need_ledger() { [ -f "$A" ] || fail "no $A yet. Run: bash scripts/audit.sh start"; }
in_ledger() { grep -qF -- "- [ ] $1 (" "$A" || grep -qF -- "- [x] $1 (" "$A"; }

cmd="${1:-}"; [ $# -gt 0 ] && shift
case "$cmd" in
start)
  if [ ! -f "$A" ]; then
    [ -f docs/plan.md ] && grep -qE '^- \[ \] ' docs/plan.md && fail "the plan still has unchecked steps. Finish them first (audit starts when everything passes)."
    [ -z "$(git status --porcelain | grep -v ' memory-bank/' || true)" ] || fail "uncommitted changes. Finish them with finish-step.sh first."
    bash scripts/verify.sh >/tmp/audit-verify.$$ 2>&1 || { tail -n 30 /tmp/audit-verify.$$; rm -f /tmp/audit-verify.$$; fail "verify is not green. Fix it first."; }
    rm -f /tmp/audit-verify.$$
    mkdir -p docs
    {
      echo "# Final audit (written only by scripts/audit.sh)"
      echo "Base: $(git rev-parse --short HEAD 2>/dev/null || echo none) | started $(date +%F)"
      echo
      echo "## Modules (mark each with: bash scripts/audit.sh seen <path>)"
      modules | while IFS= read -r f; do echo "- [ ] $f ($(wc -l < "$f" | tr -d ' ') lines)"; done
      echo
      echo "## Flows traced"
      echo
      echo "## Findings"
      echo "| id | file | sev | what | failure scenario | status |"
      echo "|---|---|---|---|---|---|"
    } > "$A"
  fi
  set_next "audit in progress: run bash scripts/audit.sh status"
  sed -n '1,40p' "$A" | grep -E '^(Base|- \[)'
  echo "AUDIT STARTED: review module by module (full read, one at a time), then run: bash scripts/audit.sh seen <path>"
  ;;
seen)
  need_ledger; p="${1:-}"; [ -n "$p" ] || fail "usage: audit.sh seen <path>"
  in_ledger "$p" || fail "'$p' is not in the module list of $A"
  awk -v p="$p" -v pre="- [ ] $p (" -v post="- [x] $p (" 'index($0,pre)==1{ $0=post substr($0,length(pre)+1) } {print}' "$A" > "$A.tmp" && mv "$A.tmp" "$A"
  echo "seen: $p. Unreviewed left: $(grep -c '^- \[ \] ' "$A")"
  ;;
add)
  need_ledger; p="${1:-}"; sev="${2:-}"; what="$(clean "${3:-}")"; scen="$(clean "${4:-}")"
  in_ledger "$p" || fail "'$p' is not in the module list of $A (use the exact path)"
  case "$sev" in BUG|RISK|NIT) :;; *) fail "severity must be BUG, RISK or NIT";; esac
  [ -n "$what" ] || fail "describe what is wrong"
  if [ "$sev" != NIT ] && [ "${#scen}" -lt 25 ]; then fail "a $sev needs a concrete failure scenario (input or state -> wrong result). No scenario, no finding."; fi
  n=$(( $(grep -cE '^\| F-[0-9]+ \|' "$A") + 1 ))
  echo "| F-$n | $p | $sev | $what | ${scen:--} | open |" >> "$A"
  echo "recorded F-$n ($sev). Next: write a failing test, fix it, finish-step.sh FIX, then audit.sh resolve F-$n fixed \"<evidence>\""
  ;;
flow)
  need_ledger; name="$(clean "${1:-}")"; tr="$(clean "${2:-}")"
  [ -n "$name" ] && [ "${#tr}" -ge 25 ] || fail "usage: audit.sh flow \"<name>\" \"<step-by-step trace with real values and the result>\""
  awk -v l="- $name: $tr" '{print} /^## Flows traced/{print l}' "$A" > "$A.tmp" && mv "$A.tmp" "$A"
  echo "flow recorded"
  ;;
resolve)
  need_ledger; id="${1:-}"; st="${2:-}"; ev="$(clean "${3:-}")"
  grep -qE "^\| $id \|" "$A" || fail "no finding $id"
  case "$st" in fixed|rejected) :;; *) fail "status must be fixed or rejected";; esac
  [ "${#ev}" -ge 8 ] || fail "give evidence (the test name that failed and now passes) or the reason for rejecting"
  if [ "$st" = fixed ]; then
    base="$(sed -n 's/^Base: \([0-9a-f]*\).*/\1/p' "$A" | head -n 1)"
    [ -n "$base" ] && [ "$(git rev-parse --short HEAD)" != "$base" ] || fail "no commit since the audit started. Fix it with a test and finish-step.sh FIX first."
  fi
  awk -v id="$id" -v s="$st: $ev" 'index($0,"| " id " |")==1{ sub(/\| open \|$/, "| " s " |") } {print}' "$A" > "$A.tmp" && mv "$A.tmp" "$A"
  echo "$id -> $st"
  ;;
status)
  need_ledger
  echo "Unreviewed modules:"; grep '^- \[ \] ' "$A" || echo "  none"
  echo "Open findings:"; grep -E '^\| F-[0-9]+ \|.*\| open \|$' "$A" || echo "  none"
  echo "Flows traced: $(sed -n '/^## Flows traced/,/^## Findings/p' "$A" | grep -c '^- ')"
  ;;
done)
  need_ledger
  left="$(grep -c '^- \[ \] ' "$A")"; [ "$left" -eq 0 ] || fail "$left module(s) not reviewed: $(grep '^- \[ \] ' "$A" | sed 's/- \[ \] //; s/ (.*//' | tr '\n' ' ')"
  flows="$(sed -n '/^## Flows traced/,/^## Findings/p' "$A" | grep -c '^- ')"; [ "$flows" -ge 1 ] || fail "no end-to-end flow traced. Trace the main flow with real numbers and record it: audit.sh flow \"<name>\" \"<trace>\""
  openbad="$(grep -E '^\| F-[0-9]+ \|.*\| (BUG|RISK) \|.*\| open \|$' "$A" | cut -d'|' -f2 | tr -d ' ' | tr '\n' ' ')"
  [ -z "$openbad" ] || fail "open BUG/RISK findings: $openbad. Fix them (test + finish-step.sh FIX + audit.sh resolve) or reject them with a reason."
  bash scripts/verify.sh >/tmp/audit-verify.$$ 2>&1 || { tail -n 30 /tmp/audit-verify.$$; rm -f /tmp/audit-verify.$$; fail "verify is red after the fixes."; }
  rm -f /tmp/audit-verify.$$
  b=$(grep -cE '^\| F-[0-9]+ \|.*\| BUG \|' "$A"); r=$(grep -cE '^\| F-[0-9]+ \|.*\| RISK \|' "$A"); nn=$(grep -cE '^\| F-[0-9]+ \|.*\| NIT \|' "$A")
  fx=$(grep -cE '^\| F-[0-9]+ \|.*\| fixed: ' "$A")
  set_next "audit finished; report to the user"
  echo "AUDIT DONE: $(grep -c '^- \[x\] ' "$A") modules reviewed, $flows flow(s) traced, BUG $b, RISK $r, NIT $nn, fixed $fx. Details: $A"
  echo "Now call attempt_completion; its first line is the AUDIT DONE line above."
  ;;
*) sed -n '2,10p' "$0"; exit 2;;
esac
