# TPL-R1 (sidekick leg), explained plainly

## What changed

Three additions to the sibling-sync section, all conditional on a templates checkout being
present: the SCHEMA extractor now has a vacuity floor (at least 20 fields must come back), a
fire-probe proves the floor catches the extractor's one known blind spot (backticked table rows
are invisible to it — a scratch copy with three rows backticked must shrink below the floor),
and a template-set arm proves every UI template key resolves to a real sibling template file.
The README now says the four are a curated subset of the sibling's six.

## Why

The templates repo grew to six this gate. The UI deliberately stays at four — but "deliberate"
needed a mechanism: the subset arm makes a renamed or deleted sibling template a named FAIL
here, while sibling extras are announced and legal. And the extractor that everything in that
section trusts had never been proven non-vacuous — the floor plus its probe close that.

## Verify it yourself

```
./scripts/validate-sidekick.sh | grep -E 'F extractor|backtick|template set'
PSYCHIC_TEMPLATES_PATH=/nonexistent ./scripts/validate-sidekick.sh | tail -3   # stated SKIP leg
```

## What could break, and what catches it

Sibling renames request-contract → the subset arm names it here. The SCHEMA table gains
backticked rows → extraction shrinks, the floor fails loudly instead of syncing against a
partial list. UI count claims stay bound by the existing §H arms — the README's first template
count is still the UI's four, asserted against the actual option list.
