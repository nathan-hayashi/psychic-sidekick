#!/usr/bin/env bash
# validate-sidekick.sh — the SDK assertion layer, born WITH the scaffold (the templates sibling
# bought this lesson at its own birth gate: controls exist from day one, fixtures are asserted to
# EXIST before any expect-fail run, and a checker never seen failing proves nothing).
set -uo pipefail
cd "$(dirname "$0")/.."
P=0; F=0; S=0
ok () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
no () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }
sk () { S=$((S+1)); printf '  [SKIP] %s\n' "$1"; }

# Needles assembled from fragments so this file never contains what it hunts (house pattern).
ABS=$(printf '/%s/' home)
CRED1="gh""p_"; CRED2="xox""b-"; CRED3="AKI""A"; CRED4="BEGIN ""PRIVATE KEY"
DOC='A field left blank is UNKNOWN and stays UNKNOWN: the executor never fills it by guess — it may ask a bounded question or proceed with the unknown recorded in the output.'

chk_synclists () { # $1=vendored $2=reference → 0 iff identical field lists
  [ -f "$1" ] && [ -f "$2" ] || return 1
  diff -q "$1" "$2" >/dev/null 2>&1
}

echo "== A. structure =="
for f in index.html js/compile.js vendor/SCHEMA-FIELDS.txt tests/compile-test.js \
         docs/INTEGRATION-CONTRACT.md README.md CLAUDE.md GATES.md; do
  [ -f "$f" ] && ok "exists: $f" || no "missing: $f"
done
for s in scripts/*.sh; do bash -n "$s" 2>/dev/null || no "syntax error in $s"; done
ok "all shell files parse"
if command -v node >/dev/null 2>&1; then
  node --check js/compile.js 2>/dev/null && ok "compile.js parses (node --check)" || no "compile.js does not parse"
else
  sk "node absent — js parse check deferred to a machine that has it"
fi

echo "== B. vocabulary binding =="
nv=$(grep -cE '^[a-z_]+$' vendor/SCHEMA-FIELDS.txt)
[[ "$nv" =~ ^[0-9]+$ ]] || nv=0
nlines=$(grep -c . vendor/SCHEMA-FIELDS.txt)
[ "$nv" -eq 22 ] && [ "$nlines" -eq 22 ] && ok "vendored vocabulary: 22 clean field names" \
  || no "vendored vocabulary malformed: $nv clean of $nlines lines (22 expected)"
# Static extraction of field tokens from the TEMPLATES block; template NAMES carry hyphens and
# self-filter out of the [a-z_]+ shape. Non-vacuity asserted before comparison.
used=$(sed -n '/^var TEMPLATES/,/^};/p' js/compile.js | grep -oE "'[a-z_]+'" | tr -d "'" | sort -u)
nused=$(grep -c . <<<"$used")
[[ "$nused" =~ ^[0-9]+$ ]] || nused=0
[ "$nused" -ge 15 ] && ok "TEMPLATES field extraction non-vacuous ($nused names)" \
  || no "TEMPLATES field extraction vacuous: $nused"
undef=$(comm -23 <(printf '%s\n' "$used") <(sort -u vendor/SCHEMA-FIELDS.txt))
[ -z "$undef" ] && ok "every compile.js template field is vendored" \
  || no "compile.js uses unvendored fields: $(tr '\n' ' ' <<<"$undef")"
topt=$(grep -c 'class="tpl-opt"' index.html)
[[ "$topt" =~ ^[0-9]+$ ]] || topt=0
[ "$topt" -eq 4 ] && ok "index.html offers exactly 4 templates" || no "template options $topt != 4"
rc=$(grep -cF "risk_class: ['low', 'med', 'high', 'crit']" js/compile.js)
[[ "$rc" =~ ^[0-9]+$ ]] || rc=0
[ "$rc" -eq 1 ] && ok "risk_class choices are exactly the single vocabulary" \
  || no "risk_class choice list drifted"

echo "== C. self-containment =="
ext=$(grep -cE '(src|href)="https?://' index.html)
[[ "$ext" =~ ^[0-9]+$ ]] || ext=1
[ "$ext" -eq 0 ] && ok "zero external src/href in index.html" || no "external references: $ext"
net=$(cat index.html js/compile.js | grep -cE 'fetch\(|XMLHttpRequest|sendBeacon|WebSocket')
[[ "$net" =~ ^[0-9]+$ ]] || net=1
[ "$net" -eq 0 ] && ok "zero network APIs in html+js" || no "network API present: $net hits"

echo "== D. doctrine =="
dn=$(grep -cF "$DOC" js/compile.js)
[[ "$dn" =~ ^[0-9]+$ ]] || dn=0
[ "$dn" -eq 1 ] && ok "doctrine verbatim once in compile.js" || no "doctrine missing/duplicated ($dn)"

echo "== E. behavioral (node) =="
if command -v node >/dev/null 2>&1; then
  if node tests/compile-test.js >/tmp/sidekick-test.out 2>&1; then
    ok "compile-test: $(grep -c '\[PASS\]' /tmp/sidekick-test.out) behavioral assertions green"
  else
    no "compile-test failed: $(grep '\[FAIL\]' /tmp/sidekick-test.out | head -3 | tr '\n' ' ')"
  fi
else
  sk "node absent — behavioral tests deferred, static bindings above still bind"
fi

echo "== E2. ui wiring (node) =="
if command -v node >/dev/null 2>&1; then
  iw=$(mktemp); iwjs="$iw.js"   # node --check demands a .js extension; plain mktemp names fail it
  awk '/<script>$/{f=1;next} /<\/script>/{f=0} f' index.html > "$iwjs"
  iwn=$(grep -c . "$iwjs")
  [[ "$iwn" =~ ^[0-9]+$ ]] || iwn=0
  [ "$iwn" -ge 20 ] && ok "inline wiring extracted non-vacuously ($iwn lines)" || no "inline wiring extraction vacuous: $iwn"
  node --check "$iwjs" 2>/dev/null && ok "inline wiring script parses" || no "inline wiring script has a syntax error"
  rm -f "$iw" "$iwjs"
else
  sk "node absent — inline wiring parse check deferred"
fi
for ident in fieldsFor computeUnknowns compileContract presetDefaults CHOICES; do
  d=$(grep -cE "^(var|function) $ident" js/compile.js)
  [[ "$d" =~ ^[0-9]+$ ]] || d=0
  u=$(grep -cF "$ident" index.html)
  [[ "$u" =~ ^[0-9]+$ ]] || u=0
  [ "$d" -ge 1 ] && [ "$u" -ge 1 ] && ok "wiring identifier bound: $ident (defined + used)" \
    || no "wiring identifier broken: $ident (defined=$d used=$u)"
done

echo "== F. sibling sync (conditional) =="
TPATH="${PSYCHIC_TEMPLATES_PATH:-../psychic-templates}"
if [ -f "$TPATH/SCHEMA.md" ]; then
  ref=$(mktemp)
  awk -F'|' '/^\| [a-z_]+ \|/{gsub(/ /,"",$2); if($2!="field") print $2}' "$TPATH/SCHEMA.md" > "$ref"
  chk_synclists vendor/SCHEMA-FIELDS.txt "$ref" && ok "vendored vocabulary matches the sibling SCHEMA" \
    || no "vendor drift: vendored list differs from the sibling SCHEMA"
  sibdoc=$(grep -F "$DOC" "$TPATH/templates/request-contract.md" | head -1)
  [ -n "$sibdoc" ] && ok "doctrine line identical to the sibling's" \
    || no "doctrine text diverged from the sibling"
  rm -f "$ref"
else
  sk "sibling checkout not present at \$PSYCHIC_TEMPLATES_PATH or ../psychic-templates — sync deferred, stated"
fi

echo "== G. hygiene =="
abshits=$(git ls-files -z | xargs -0 grep -lF -- "$ABS" 2>/dev/null)
[ -z "$abshits" ] && ok "no absolute machine paths in tracked files" || no "absolute path in: $(tr '\n' ' ' <<<"$abshits")"
credhits=""
for ndl in "$CRED1" "$CRED2" "$CRED3" "$CRED4"; do
  h=$(git ls-files -z | xargs -0 grep -lF -- "$ndl" 2>/dev/null)
  [ -n "$h" ] && credhits="$credhits $h"
done
[ -z "$credhits" ] && ok "no credential-shaped strings in tracked files" || no "credential shape in:$credhits"

echo "== H. README count bindings =="
r22=$(grep -oE '\*\*[0-9]+ fields\*\*' README.md 2>/dev/null | head -1 | grep -oE '[0-9]+')
[[ "$r22" =~ ^[0-9]+$ ]] || r22=-1
[ "$r22" -eq "$nlines" ] && ok "README field count ($r22) matches the vendored list ($nlines)" \
  || no "README says $r22 fields, vendor has $nlines"
r4=$(grep -oE '\*\*[0-9]+ templates\*\*' README.md 2>/dev/null | head -1 | grep -oE '[0-9]+')
[[ "$r4" =~ ^[0-9]+$ ]] || r4=-1
[ "$r4" -eq "$topt" ] && ok "README template count ($r4) matches the UI ($topt)" \
  || no "README says $r4 templates, the UI offers $topt"

echo "== I. negative controls (existence first, then fire) =="
for fx in tests/fixtures/bad-vendor-drift.txt; do
  [ -f "$fx" ] && ok "fixture exists: $fx" || no "fixture MISSING (controls would be vacuous): $fx"
done
chk_synclists vendor/SCHEMA-FIELDS.txt tests/fixtures/bad-vendor-drift.txt \
  && no "control DID NOT fire: drifted vendor list accepted" || ok "control fires: vendor drift caught"
chk_synclists vendor/SCHEMA-FIELDS.txt tests/fixtures/does-not-exist.txt \
  && no "control DID NOT fire: phantom reference passed sync" || ok "control fires: phantom path refused"

echo "== J. browser render (conditional) =="
# A real engine executing the page beats any static read of it — but only when a browser already
# exists on the host. This repo installs nothing, so absence is a stated SKIP, never a quiet pass.
BROWSER=""
for c in chromium chromium-browser google-chrome google-chrome-stable; do
  b=$(command -v "$c" 2>/dev/null)
  if [ -n "$b" ]; then BROWSER="$b"; break; fi
done
if [ -z "$BROWSER" ]; then
  for b in "$HOME"/.cache/ms-playwright/chromium-*/chrome-linux*/chrome; do
    if [ -x "$b" ]; then BROWSER="$b"; break; fi
  done
fi
if [ -n "$BROWSER" ]; then
  dom=$(mktemp)
  "$BROWSER" --headless=new --disable-gpu --no-sandbox --virtual-time-budget=2000 \
    --dump-dom "file://$(pwd)/index.html" > "$dom" 2>/dev/null
  nf=$(grep -o 'data-field="' "$dom" | wc -l)
  [[ "$nf" =~ ^[0-9]+$ ]] || nf=0
  [ "$nf" -ge 9 ] && ok "rendered DOM carries $nf data-field inputs (wiring executed)" \
    || no "rendered DOM has only $nf data-field inputs — wiring did not run"
  strip=$(grep -c 'UNKNOWN at compile:' "$dom")
  [[ "$strip" =~ ^[0-9]+$ ]] || strip=0
  [ "$strip" -ge 1 ] && ok "live UNKNOWN strip rendered" || no "UNKNOWN strip absent from rendered DOM"
  rm -f "$dom"
else
  sk "no browser binary on this host — rendered-DOM check deferred, stated"
fi


# S0-RECONCILE — the explainer-epoch discipline, ported from the parent with ONE DECLARED
# VARIANCE: an empty post-epoch set is PASS-with-reason here (this repo gates rarely, so the
# epoch row is often the last row); the parent's stricter FAIL stands over there. Grandfathered
# rows (enumerated in INDEX.md) are events recorded without tokens and owe no explainer.
exepoch=$(grep -m1 '^EXPLAINER-EPOCH: ' docs/explainers/INDEX.md 2>/dev/null | awk '{print $2}')
exgf=$(grep -m1 '^EXPLAINER-GRANDFATHERED: ' docs/explainers/INDEX.md 2>/dev/null | sed 's/^EXPLAINER-GRANDFATHERED: //')
if [ -z "${exepoch:-}" ]; then
  no "explainer epoch line missing from docs/explainers/INDEX.md"
else
  exrows=$(awk -F'|' -v ep="$exepoch" '/^\| [A-Za-z]/ { g=$2; gsub(/^ +| +$/,"",g); if (found && g!="Gate") print g; if (g==ep) found=1 }' GATES.md)
  exmiss=""
  for g in $exrows; do
    case " ${exgf:-} " in *" $g "*) continue ;; esac
    [ -f "docs/explainers/$g.md" ] || exmiss="$exmiss [$g]"
  done
  if [ -z "$exrows" ]; then
    ok "explainer epoch: post-epoch set empty (epoch is the last row) — PASS with stated reason (declared variance)"
  elif [ -z "$exmiss" ]; then
    ok "every post-epoch gate has its plain-language explainer"
  else
    no "explainer(s) MISSING for post-epoch gate(s):$exmiss"
  fi
  exfx=$(mktemp); cat GATES.md > "$exfx"
  printf '| PROBE-X9 |  | p | p | awaiting probe |\n' >> "$exfx"
  exrows2=$(awk -F'|' -v ep="$exepoch" '/^\| [A-Za-z]/ { g=$2; gsub(/^ +| +$/,"",g); if (found && g!="Gate") print g; if (g==ep) found=1 }' "$exfx")
  case "$exrows2" in
    *"PROBE-X9"*) ok "explainer fire-probe: a planted post-epoch gate row is seen by the extractor" ;;
    *) no "explainer fire-probe FAILED — a planted row went unseen; the binding is void" ;;
  esac
  rm -f "$exfx"
fi

echo "== validate-sidekick: $P PASS / $F FAIL / $S SKIP =="
[ "$F" -eq 0 ]
