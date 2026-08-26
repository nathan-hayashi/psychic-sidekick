#!/usr/bin/env bash
# gate-guard.sh — minimal port of the parent's guard: a commit under a token is legal only if
# this repo's own GATES.md carries that token in an APPROVED row. The guard reads its own ledger,
# never the operator's mood.
set -uo pipefail
cd "$(dirname "$0")/.."
tok="${1:-}"
[ -n "$tok" ] || { echo "gate-guard: usage: gate-guard.sh \"APPROVE <ID>\"" >&2; exit 2; }
n=$(grep -cF "**APPROVED** \`$tok\`" GATES.md)
[[ "$n" =~ ^[0-9]+$ ]] || n=0
if [ "$n" -ge 1 ]; then
  echo "gate-guard: ok — \"$tok\" is APPROVED in GATES.md ($n row(s))."
  exit 0
fi
if grep -qF "\`$tok\`" GATES.md; then
  echo "gate-guard: REFUSED — \"$tok\" has no APPROVED row in GATES.md."
  echo "  the row exists and is still awaiting the operator. Stop and ask; do not commit."
else
  echo "gate-guard: REFUSED — no row mentions that token."
fi
exit 1
