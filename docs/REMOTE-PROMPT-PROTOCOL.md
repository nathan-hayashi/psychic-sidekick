# REMOTE-PROMPT-PROTOCOL — the phone lane, formalized (SIDE-R1)

## 1. What "remote" declares

The operator marks a prompt as remote (by choosing the remote lane in sidekick, or by saying so).
That declaration means: the mobile/remote Claude session owns the turn end-to-end. The operator is
a sender, not an available respondent.

## 2. Run to completion — a DECLARED INVERSION, stated out loud

This lane deliberately inverts the estate's fallback rule 3 ("below 0.6 confidence on a
load-bearing step, return a question, not a guess"). In a remote turn the session does NOT stop to
ask: it proceeds on the best defensible reading and RECORDS the judgment instead. Inverting a
binding rule silently is this estate's most-recorded defect class — hence this section. The
inversion is scoped to remote-declared turns only, and irreversible/destructive actions remain
outside it: those still require their own explicit approval and are recorded as escalations.

## 3. Escalation recording

Every proceeded-past judgment lands in the reply in one greppable shape:

`ESCALATION: <what> | <why it did not block> | <what the operator must decide>`

The turn ends with a summary: done / escalated / remaining.

## 4. The verbatim preamble (machine-bound — do not edit here without the twin)

This block is byte-compared by the validator (section D2) against the `REMOTE_PREAMBLE` constant
in `js/compile.js`. Two files, one assertion, delta zero — the vendored-vocabulary pattern inside
one repo. Edit BOTH or the suite is red.

```text
# REMOTE-PREAMBLE v1
REMOTE PROMPT PROTOCOL v1 - this prompt was sent from a remote/mobile session by the operator.
Run the request below to completion in this one turn: do not stop mid-task to ask questions.
Where you would normally block on a low-confidence step, proceed on the best defensible reading.
Record every such judgment as: ESCALATION: <what> | <why it did not block> | <what the operator must decide>.
Irreversible or destructive actions stay forbidden without their own explicit approval - record those as escalations too.
End with a summary: what was done, what was escalated, what remains.
---
```

## 5. What this lane does NOT grant — and what is not asserted

No credential, no network request, no agent invocation: the phone is a keyboard, the human is the
transport, the clipboard is still the boundary (the INTEGRATION-CONTRACT is unchanged on this).
And the honest limit, stated the way the intake skill states its own: NOTHING MECHANICAL PROVES a
mobile session honors this preamble. Adherence is model-interpreted per session. What the suite
proves is only that the preamble the UI ships is byte-identical to the protocol recorded here.
