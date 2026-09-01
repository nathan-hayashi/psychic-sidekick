# Explainers — the plain-language layer (ported at S0-RECONCILE)

Every gate after the epoch below ships a plain-language explainer here: what changed, why, what
each piece does, how to verify it yourself, and what could break. The audit record stays in
GATES.md and the parent program's ledgers; this layer is the trust surface.

## Epoch (machine-read by the validator — do not reword the next two lines)

EXPLAINER-EPOCH: SDK-0
EXPLAINER-GRANDFATHERED: VIS-RECONCILE

Rows after the epoch in GATES.md must each have `docs/explainers/<GATE>.md`. Grandfathered rows
(above, enumerated) are retroactive records of events that had no token and owe no explainer.
DECLARED VARIANCE from the parent: an empty post-epoch set PASSES with a stated reason here —
this repo gates rarely, and the epoch row may legitimately be the last row.

## Explainers

- [S0-RECONCILE](S0-RECONCILE.md) — license, identity, visibility truth, and this discipline itself.
- [SIDE-R1](SIDE-R1.md) — the remote lane's brain: the preamble, the pack, the declared inversion.
