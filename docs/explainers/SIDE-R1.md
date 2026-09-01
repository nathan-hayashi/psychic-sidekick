# SIDE-R1, explained plainly

## What changed

Sidekick learned the remote lane's brain (the phone surface comes next gate): a protocol preamble
that turns a mobile Claude session into a run-to-completion executor, a `compilePromptPack`
function that wraps your compiled contract in it, and a protocol document that says — out loud —
that this lane inverts the usual ask-when-unsure rule and records judgments instead of blocking.

## Why

You already work this way from your phone; this writes it down and makes it shippable. The
preamble lives in two places (the code that ships it, the doc that governs it), so the validator
byte-compares them — a drifted copy is a red suite, not a silent divergence.

## Verify it yourself

```
./scripts/validate-sidekick.sh          # D2 byte-identity + its drift control
node tests/compile-test.js              # the pack wraps, never rewrites
grep -A3 'DECLARED INVERSION' docs/REMOTE-PROMPT-PROTOCOL.md
```

## What could break, and what catches it

Edit the preamble in one file only → D2 fails naming the drift. Break the wrapper → the node
tests fail. Nothing mechanical proves a mobile session obeys the preamble — the protocol doc says
exactly that in its own honesty section, instead of implying otherwise.
