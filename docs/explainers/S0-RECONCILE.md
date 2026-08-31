# S0-RECONCILE, explained plainly

## What changed

This repo gained a LICENSE (MIT, copyright Nathan Lim), a one-line canonical author identity in
its law file, and this explainer discipline — every future gate here ships a plain-language
explainer like this one, checked by the validator. Its ledger also gains a retroactive row recording honestly that the repo was flipped public
out-of-band after birth — the flip is ratified, the history is preserved, and the README now
says PUBLIC instead of a stale claim.

## Why

Five estate repos were already public with no license at all, which legally means "all rights
reserved" — the opposite of what a reference estate wants. And three repos' docs still claimed
they were private, which stopped being true at some unrecorded moment; the honest fix is to
record what happened, not to rewrite old statements.

## Verify it yourself

```
head -3 LICENSE                      # MIT License / Copyright (c) 2026 Nathan Lim
grep EXPLAINER-EPOCH docs/explainers/INDEX.md
./scripts/validate-sidekick.sh          # the two new explainer checks: PASS
tail -3 GATES.md                     # the honest ledger rows
```

## What could break, and what catches it

A future gate here without its explainer fails the validator by gate name. Deleting the epoch
line fails it by name too. The planted-row fire-probe proves the extractor actually sees new rows.
