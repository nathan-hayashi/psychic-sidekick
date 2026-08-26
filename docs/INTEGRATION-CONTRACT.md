# INTEGRATION CONTRACT — psychic-sidekick ↔ its neighbors

The coupling, declared rather than discovered (the parent program's §7.1 relation-model
precedent: two artifacts that depend on each other state the dependency in a file a check can
read, or the dependency is drift waiting to be found).

## What this repo consumes

- **The psychic-templates canonical vocabulary** — 22 field names, vendored at
  `vendor/SCHEMA-FIELDS.txt`. Provenance: extracted from the sibling's `SCHEMA.md` field tables
  at vendoring time. The vendored copy is the runtime truth for this UI; the sibling remains the
  canonical source. Reconciliation is mechanical: validator section F diffs the two whenever a
  sibling checkout exists (`PSYCHIC_TEMPLATES_PATH`, defaulting to a side-by-side layout) and
  FAILS on any difference. When no checkout exists the check is a stated SKIP — deferred, never
  silently passed.
- **The UNKNOWN doctrine**, verbatim — one line, identical bytes in the sibling's templates and
  this repo's `js/compile.js`; equality is asserted in the same section F.

## What this repo produces

One artifact: a compiled request contract in markdown, field-ordered per its template, blanks
rendered as `UNKNOWN`, with `unknown_fields` computed — never typed — and the doctrine appended.
A human copies it into a Claude session. **Sidekick never invokes an agent, never sends a
request, never holds a credential.** The hand-off is a paste; the boundary is the clipboard.

## Presets — provenance and the honest limit

Department presets (finance / engineering / marketing) fill `context_policy`-family defaults and
a risk floor, grounded `[I]` in the parent's RSCH-3 tier table (`docs/research/RSCH-3-tei-matrix.md`
§C). They are conveniences for a person filling a form. They are NOT the TEI-3 per-department
authority-resolver, which does not exist and is the program's flagged weakest claim — whether a
department's approval rules can be expressed deterministically at all is an open experiment,
staged last in TEI-PREPLAN precisely because it may fail. Until that experiment runs, nothing in
this UI decides who may approve what; the `approval` field records a human act.

## Failure semantics

| Condition | Behavior |
|---|---|
| Vendored list drifts from sibling SCHEMA | validator FAIL (section F), release blocked |
| Sibling checkout absent | stated SKIP; static bindings (sections B/D) still bind |
| node absent | behavioral tests stated SKIP; parse+binding checks still bind |
| Template/field added upstream | vendor refresh is a GATED change here, never a quiet edit |

## Versioning

The vendored vocabulary changes only under this repo's own gate, citing the sibling commit it
was re-extracted from. A silent vendor refresh is the drift class this contract exists to kill.
