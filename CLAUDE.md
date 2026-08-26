# psychic-sidekick — law

The Request-Contract front end: a fill-in-the-fields, multiple-choice UI that compiles a person's
inputs into a psychic-templates contract and hands the result to a Claude session. Born 2026-08-26
under the parent HELIX program's SIDE-1 gate (psychic-crew). PRIVATE at creation.

## Binding rules
- **Zero-dependency UI.** `index.html` + `js/compile.js` run from `file://` or any static server.
  No CDN, no install, no network request of any kind. The validator asserts self-containment.
- **The vocabulary is vendored, never invented.** `vendor/SCHEMA-FIELDS.txt` is a copy of the
  psychic-templates canonical field list; a sync check diffs it against the sibling checkout when
  one is present. Drift is a FAIL, not a fork.
- **Presets are conveniences, never authority.** Department presets fill editable defaults
  grounded in the parent's RSCH-3 tier table. The TEI-3 authority-resolver does not exist yet
  (it is the program's flagged weakest claim); nothing in this UI grants approval — approval is
  a human act recorded in its field.
- **The UNKNOWN doctrine is mechanized:** any field left blank compiles to UNKNOWN and lands in
  `unknown_fields` automatically. The UI never fills a gap by guess; that is the product.
- **Evidence labels** ([E]/[I]/[S]) on load-bearing claims; weakest claim flagged per deliverable.
- **Gate law.** Exact operator tokens in `GATES.md`; commits fronted by `scripts/gate-guard.sh`.
- **One risk vocabulary:** low | med | high | crit. **No absolute machine paths. Zero credentials.**
