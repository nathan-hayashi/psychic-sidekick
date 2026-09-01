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


echo "== D2. remote preamble — two files, one byte-identity (SIDE-R1) =="
d2js=$(grep -m1 "^var REMOTE_PREAMBLE = '" js/compile.js | sed -E "s/^var REMOTE_PREAMBLE = '(.*)';$/\\1/")
d2doc=$(awk '/^# REMOTE-PREAMBLE v1$/{f=1;next} f&&/^```/{exit} f' docs/REMOTE-PROMPT-PROTOCOL.md)
d2jsd=$(printf '%b' "$d2js")
d2jn=$(printf '%s\n' "$d2jsd" | grep -c . || true); [[ "$d2jn" =~ ^[0-9]+$ ]] || d2jn=0
d2dn=$(printf '%s\n' "$d2doc" | grep -c . || true); [[ "$d2dn" =~ ^[0-9]+$ ]] || d2dn=0
{ [ "$d2jn" -ge 6 ] && [ "$d2dn" -ge 6 ]; } \
  && ok "D2 both preamble sources non-vacuous (js $d2jn / doc $d2dn lines)" \
  || no "D2 extraction vacuous — js:$d2jn doc:$d2dn (want >=6 each)"
if [ "$(printf '%s' "$d2jsd")" = "$(printf '%s' "$d2doc")" ]; then
  ok "D2 preamble byte-identical: compile.js == protocol doc"
else
  no "D2 PREAMBLE DRIFT — compile.js and the protocol doc disagree"
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
for ident in fieldsFor computeUnknowns compilePromptPack presetDefaults CHOICES; do
  d=$(grep -cE "^(var|function) $ident" js/compile.js)
  [[ "$d" =~ ^[0-9]+$ ]] || d=0
  u=$(grep -cF "$ident" index.html)
  [[ "$u" =~ ^[0-9]+$ ]] || u=0
  [ "$d" -ge 1 ] && [ "$u" -ge 1 ] && ok "wiring identifier bound: $ident (defined + used)" \
    || no "wiring identifier broken: $ident (defined=$d used=$u)"
done


echo "== E2r. lane identifiers (defined + exported + test-exercised; the pack also rides §E2 since SIDE-R2) =="
for ident in REMOTE_PREAMBLE compilePromptPack compileContract; do
  d=$(grep -cE "^(var|function) $ident" js/compile.js); [[ "$d" =~ ^[0-9]+$ ]] || d=0
  e=$(grep -cF "$ident: $ident" js/compile.js); [[ "$e" =~ ^[0-9]+$ ]] || e=0
  x=$(grep -cF "$ident" tests/compile-test.js); [[ "$x" =~ ^[0-9]+$ ]] || x=0
  { [ "$d" -ge 1 ] && [ "$e" -ge 1 ] && [ "$x" -ge 1 ]; } \
    && ok "remote identifier bound: $ident (defined+exported+tested)" \
    || no "remote identifier broken: $ident (defined=$d exported=$e tested=$x)"
done


echo "== E3. the phone surface (static, every clone; SIDE-R2) =="
mq=$(grep -c '@media (max-width:' index.html); [[ "$mq" =~ ^[0-9]+$ ]] || mq=0
[ "$mq" -eq 1 ] && ok "one phone width query governs the mobile law" || no "phone width query count $mq != 1"
p16=$(grep -c 'font-size: 16px' index.html); [[ "$p16" =~ ^[0-9]+$ ]] || p16=0
[ "$p16" -ge 1 ] && ok "16px input law present (mobile browsers never zoom-jump)" || no "16px input law missing"
p44=$(grep -c 'min-height: 44px' index.html); [[ "$p44" =~ ^[0-9]+$ ]] || p44=0
[ "$p44" -ge 1 ] && ok "44px tap-target law present" || no "44px tap-target law missing"
stk=$(grep -c 'position: sticky' index.html); [[ "$stk" =~ ^[0-9]+$ ]] || stk=0
[ "$stk" -ge 1 ] && ok "sticky compile bar law present" || no "sticky compile bar law missing"
lopt=$(grep -c 'class="lane-opt"' index.html); [[ "$lopt" =~ ^[0-9]+$ ]] || lopt=0
lsw=$(grep -c 'data-sw="' index.html); [[ "$lsw" =~ ^[0-9]+$ ]] || lsw=0
{ [ "$lopt" -eq 2 ] && [ "$lsw" -eq 2 ]; } && ok "exactly 2 lanes by both anchors (lane-opt, data-sw)" \
  || no "lane anchors disagree or drifted: lane-opt=$lopt data-sw=$lsw (2 expected)"
rlane=$(grep -oE '\*\*[0-9]+ lanes\*\*' README.md | grep -oE '[0-9]+' | sort -u)
rlN=$(grep -c . <<<"$rlane"); [[ "$rlN" =~ ^[0-9]+$ ]] || rlN=0
{ [ "$rlN" -eq 1 ] && [ "$rlane" = "$lopt" ]; } && ok "README lane count bound every-occurrence (**$rlane lanes** == UI $lopt)" \
  || no "README lane binding broken: distinct values [$rlane] vs UI $lopt"
wmax=$(grep -oE '(max-)?width: *[0-9]+px' index.html | grep -v '^max-' | grep -oE '[0-9]+' | sort -n | tail -1)
[ -n "$wmax" ] || wmax=0
[ "$wmax" -le 480 ] && ok "no bare fixed width beyond phones (max ${wmax}px)" \
  || no "fixed width ${wmax}px would overflow a phone"
e3sc=$(mktemp -d)
cp -r . "$e3sc/repo" 2>/dev/null
sed -i.bak 's|</body>|<div style="width: 900px">overflow probe</div></body>|' "$e3sc/repo/index.html" && rm -f "$e3sc/repo/index.html.bak"
plant=$(grep -c 'width: 900px' "$e3sc/repo/index.html"); [[ "$plant" =~ ^[0-9]+$ ]] || plant=0
[ "$plant" -eq 1 ] && ok "E3 probe planted (asserted before the guard is asked to refuse)" || no "E3 probe DID NOT plant"
wprobe=$(grep -oE '(max-)?width: *[0-9]+px' "$e3sc/repo/index.html" | grep -v '^max-' | grep -oE '[0-9]+' | sort -n | tail -1)
[ -n "$wprobe" ] || wprobe=0
[ "$wprobe" -gt 480 ] && ok "control fires: the overflow scanner catches the planted 900px div" \
  || no "control DID NOT fire — a 900px plant passed the scanner"
rm -rf "$e3sc"

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
  refn=$(grep -c . "$ref"); [[ "$refn" =~ ^[0-9]+$ ]] || refn=0
  [ "$refn" -ge 20 ] && ok "F extractor non-vacuous ($refn sibling fields, floor 20)" \
    || no "F extractor vacuous: $refn fields from the sibling SCHEMA (want >= 20)"
  fbt=$(mktemp)
  sed -E 's/^\| (goal|risk_class|approval) \|/| `\1` |/' "$TPATH/SCHEMA.md" > "$fbt"
  fbtn=$(awk -F'|' '/^\| [a-z_]+ \|/{gsub(/ /,"",$2); if($2!="field") print $2}' "$fbt" | grep -c .)
  [[ "$fbtn" =~ ^[0-9]+$ ]] || fbtn=0
  { [ "$fbtn" -eq $((refn-3)) ] && [ "$fbtn" -lt 20 ]; } \
    && ok "control fires: backticked rows are invisible to the extractor AND the floor catches the shrink ($fbtn)" \
    || no "backtick fire-probe broken: $fbtn (want $((refn-3)) and < 20) — the subset-blind hole is open"
  rm -f "$fbt"
  uikeys=$(sed -n '/^var TEMPLATES = {/,/^};/p' js/compile.js | grep -oE "'[a-z-]+': \[" | sed -E "s/^'([a-z-]+)': \[$/\1/" | sort)
  sibstems=$(ls "$TPATH"/templates/*.md 2>/dev/null | sed -E 's|.*/||; s|\.md$||' | sort)
  fex=$(comm -13 <(printf '%s\n' "$uikeys") <(printf '%s\n' "$sibstems") | grep -c .)
  fmiss=$(comm -23 <(printf '%s\n' "$uikeys") <(printf '%s\n' "$sibstems"))
  [ -z "$fmiss" ] && ok "template set: every UI key resolves to a sibling template (UI subset; $fex sibling extra(s) legal, announced)" \
    || no "UI template(s) missing from the sibling: $(tr '\n' ' ' <<<"$fmiss")"
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
r22v=$(grep -oE '\*\*[0-9]+ fields\*\*|badge/fields-[0-9]+' README.md 2>/dev/null | grep -oE '[0-9]+' | sort -u)
r22n=$(grep -c . <<<"$r22v"); [[ "$r22n" =~ ^[0-9]+$ ]] || r22n=0
{ [ "$r22n" -eq 1 ] && [ "$r22v" = "$nlines" ]; } \
  && ok "README field count bound every-occurrence incl. the badge ($r22v == vendor $nlines)" \
  || no "README field binding broken: distinct values [$(tr '\n' ' ' <<<"$r22v")] vs vendor $nlines"
r4v=$(grep -oE '\*\*[0-9]+ templates\*\*' README.md 2>/dev/null | grep -oE '[0-9]+' | sort -u)
r4n=$(grep -c . <<<"$r4v"); [[ "$r4n" =~ ^[0-9]+$ ]] || r4n=0
{ [ "$r4n" -eq 1 ] && [ "$r4v" = "$topt" ]; } \
  && ok "README template count bound every-occurrence ($r4v == UI $topt; the sibling's six is deliberately unbindable prose)" \
  || no "README template binding broken: distinct values [$(tr '\n' ' ' <<<"$r4v")] vs UI $topt"
hcp=$(mktemp); cat README.md > "$hcp"; printf '\nbadge/fields-99\n**9 templates**\n' >> "$hcp"
h2a=$(grep -oE '\*\*[0-9]+ fields\*\*|badge/fields-[0-9]+' "$hcp" | grep -oE '[0-9]+' | sort -u | grep -c .)
h2b=$(grep -oE '\*\*[0-9]+ templates\*\*' "$hcp" | grep -oE '[0-9]+' | sort -u | grep -c .)
[[ "$h2a" =~ ^[0-9]+$ ]] || h2a=0; [[ "$h2b" =~ ^[0-9]+$ ]] || h2b=0
{ [ "$h2a" -ge 2 ] && [ "$h2b" -ge 2 ]; } \
  && ok "controls fire: planted conflicting badge and prose counts reach both extractors" \
  || no "every-occurrence controls DID NOT fire (fields probe $h2a, templates probe $h2b)"
rm -f "$hcp"

echo "== I. negative controls (existence first, then fire) =="
[ -f tests/fixtures/bad-preamble-drift.txt ] && ok "fixture exists: bad-preamble-drift.txt" \
  || no "missing fixture: bad-preamble-drift.txt"
d2fx=$(cat tests/fixtures/bad-preamble-drift.txt 2>/dev/null)
if [ "$(printf '%s' "$d2jsd")" = "$(printf '%s' "$d2fx")" ]; then
  no "D2 control VOID — the drift fixture equals the live preamble"
else
  ok "control fires: the D2 comparator distinguishes the drifted fixture"
fi
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



echo "== J2. phone render (conditional — a stated SKIP wherever no browser ships; SIDE-R2) =="
if [ -n "$BROWSER" ]; then
  j2d=$(mktemp)
  "$BROWSER" --headless=new --disable-gpu --no-sandbox --window-size=390,844 --virtual-time-budget=2000 \
    --dump-dom "file://$(pwd)/index.html" > "$j2d" 2>/dev/null
  j2l=$(grep -o 'class="lane-opt"' "$j2d" | wc -l); [[ "$j2l" =~ ^[0-9]+$ ]] || j2l=0
  [ "$j2l" -eq 2 ] && ok "J2 rendered DOM offers both lanes at phone viewport" \
    || no "J2 lanes in rendered DOM: $j2l (2 expected)"
  j2f=$(grep -o 'data-field="' "$j2d" | wc -l); [[ "$j2f" =~ ^[0-9]+$ ]] || j2f=0
  [ "$j2f" -ge 9 ] && ok "J2 wiring executed at 390px ($j2f data-field inputs)" \
    || no "J2 wiring did not run at phone viewport ($j2f inputs)"
  rm -f "$j2d"
  j2r=$(mktemp -d)
  cp -r . "$j2r/fit" 2>/dev/null
  sed -i.bak 's|</body>|<script>document.title = (document.documentElement.scrollWidth > window.innerWidth) ? "J2-OVERFLOW" : "J2-FITS";</script></body>|' "$j2r/fit/index.html" && rm -f "$j2r/fit/index.html.bak"
  mplant=$(grep -c 'J2-OVERFLOW' "$j2r/fit/index.html"); [[ "$mplant" =~ ^[0-9]+$ ]] || mplant=0
  [ "$mplant" -eq 1 ] && ok "J2 fit meter planted in the scratch copy" || no "J2 fit meter DID NOT plant"
  fitdom=$(mktemp)
  "$BROWSER" --headless=new --disable-gpu --no-sandbox --window-size=390,844 --virtual-time-budget=2000 \
    --dump-dom "file://$j2r/fit/index.html" > "$fitdom" 2>/dev/null
  fita=$(grep -c '<title>J2-FITS</title>' "$fitdom"); [[ "$fita" =~ ^[0-9]+$ ]] || fita=0
  [ "$fita" -eq 1 ] && ok "J2 live layout FITS a 390px phone (measured in-engine)" \
    || no "J2 layout overflows at 390px, or the meter went silent"
  cp -r . "$j2r/probe" 2>/dev/null
  sed -i.bak 's|</body>|<div style="width: 900px">p</div><script>document.title = (document.documentElement.scrollWidth > window.innerWidth) ? "J2-OVERFLOW" : "J2-FITS";</script></body>|' "$j2r/probe/index.html" && rm -f "$j2r/probe/index.html.bak"
  pdom=$(mktemp)
  "$BROWSER" --headless=new --disable-gpu --no-sandbox --window-size=390,844 --virtual-time-budget=2000 \
    --dump-dom "file://$j2r/probe/index.html" > "$pdom" 2>/dev/null
  pova=$(grep -c '<title>J2-OVERFLOW</title>' "$pdom"); [[ "$pova" =~ ^[0-9]+$ ]] || pova=0
  [ "$pova" -eq 1 ] && ok "J2 control fires: the planted 900px div reports OVERFLOW in-engine" \
    || no "J2 control DID NOT fire — a 900px plant rendered as fitting"
  rm -f "$fitdom" "$pdom"; rm -rf "$j2r"
else
  sk "no browser on this host — J2 render legs are the operator machine's drill (declared; the E3 static arms above run everywhere)"
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
