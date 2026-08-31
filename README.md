# psychic-sidekick

The Request-Contract front end: a fill-in-the-fields, multiple-choice page that compiles what a
person actually knows into a [psychic-templates](https://github.com/nathan-hayashi/psychic-templates)
contract — and turns everything they *don't* know into an explicit `unknown_fields` list instead
of a guess. The doctrine, mechanized: blank never becomes plausible.

**PUBLIC** since an out-of-band flip after creation (flip date unrecorded — gh pushedAt matches
the birth commit; ratified 2026-08-31, see the VIS-RECONCILE ledger row). Private at creation.

## Quickstart

```bash
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/nathan-hayashi/psychic-sidekick.git
cd psychic-sidekick && ./scripts/validate-sidekick.sh
```

Then open `index.html` in a browser — straight from `file://`, or via
`python3 -m http.server 8080` if you prefer a served page. There is no build step, no install,
no network call: one HTML file, one plain-JS core.

## What it does

1. Pick one of **4 templates** (request-contract, high-stakes-task, context-policy,
   audit-checklist) — the same four the templates repo defines.
2. Optionally pick a department preset (finance / engineering / marketing). **Presets fill
   editable defaults, grounded in the parent program's tier table. They are not policy, and
   nothing here grants approval** — approval is a human act recorded in its own field.
3. Fill what you know. Multiple-choice fields (risk class, approval, yes/no gates) only offer
   legal values; everything else is free text. A live strip shows exactly what will compile
   as UNKNOWN.
4. Compile, copy, and paste the contract into your Claude session. The contract is the interface.

## The vocabulary is vendored, not invented

`vendor/SCHEMA-FIELDS.txt` carries the **22 fields** of the psychic-templates canonical schema.
The validator sync-checks it against a sibling checkout when one is present (set
`PSYCHIC_TEMPLATES_PATH` or keep the two repos side by side); drift is a FAIL, not a fork.
`docs/INTEGRATION-CONTRACT.md` declares the full coupling.

## Verification

`./scripts/validate-sidekick.sh` — structure, vocabulary bindings both directions,
self-containment (zero external references, zero network APIs), the doctrine verbatim, node
behavioral tests when node is present (stated SKIP when not), sibling sync, hygiene, README
count bindings, negative controls proven to fire against planted fixtures, and a rendered-DOM
browser check whenever a browser binary is already on the host (stated SKIP otherwise).
