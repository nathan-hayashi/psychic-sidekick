// compile.js — the pure core of psychic-sidekick. No DOM, no network, no dependency.
// Loaded by index.html as a plain script AND runnable under node for the behavioral tests.
// The UNKNOWN doctrine is mechanized here: computeUnknowns() is the product.

var DOCTRINE = 'A field left blank is UNKNOWN and stays UNKNOWN: the executor never fills it by guess — it may ask a bounded question or proceed with the unknown recorded in the output.';

// Multiple-choice fields and their only legal values (the single risk vocabulary among them).
var CHOICES = {
  risk_class: ['low', 'med', 'high', 'crit'],
  approval: ['none', 'acknowledgement', 'quoted approval', 'exact gate token'],
  internal_only: ['yes', 'no'],
  indeterminate_allowed: ['yes', 'no']
};

// Field order per template — mirrors the four Fields blocks in psychic-templates byte-for-name.
// unknown_fields is terminal and COMPUTED, never typed.
var TEMPLATES = {
  'request-contract': ['goal', 'completion_condition', 'context_refs', 'constraints_hard',
    'non_goals', 'output_shape', 'risk_class', 'approval', 'verification_mechanism',
    'unknown_fields'],
  'high-stakes-task': ['goal', 'completion_condition', 'context_refs', 'constraints_hard',
    'constraints_soft', 'priority_on_conflict', 'non_goals', 'output_shape', 'evidence_labels',
    'weakest_claim', 'iteration_protocol', 'restatement_cadence', 'risk_class', 'approval',
    'verification_mechanism', 'indeterminate_allowed', 'unknown_fields'],
  'context-policy': ['risk_class', 'sources_allowed', 'internal_only', 'distribution_filter',
    'credentials', 'expiration', 'unknown_fields'],
  'audit-checklist': ['goal', 'completion_condition', 'evidence_labels', 'weakest_claim',
    'iteration_protocol', 'restatement_cadence', 'output_shape', 'non_goals', 'unknown_fields']
};

// Department presets: EDITABLE DEFAULTS grounded in the parent's RSCH-3 tier table [I].
// They are not policy. The TEI-3 authority-resolver does not exist; nothing here grants approval.
var PRESETS = {
  finance: {
    risk_class: 'high',
    approval: 'quoted approval',
    internal_only: 'yes',
    sources_allowed: 'the finance export the operator placed in the workspace; no live systems',
    distribution_filter: 'controller and counsel review before anything leaves the boundary',
    credentials: 'zero — a grant needs its own gate, minimum surface, named expiry',
    expiration: 'this engagement',
    constraints_hard: 'no fabricated figures; every number cites its source file'
  },
  engineering: {
    risk_class: 'med',
    approval: 'acknowledgement',
    internal_only: 'yes',
    sources_allowed: 'the named repositories only',
    distribution_filter: 'engineering lead review; public excerpts only via the repo’s own gate',
    credentials: 'zero — a grant needs its own gate, minimum surface, named expiry',
    expiration: 'this sprint',
    constraints_hard: 'no dependency additions without their own approval; suites green before any claim'
  },
  marketing: {
    risk_class: 'med',
    approval: 'quoted approval',
    internal_only: 'no',
    sources_allowed: 'the approved brand-assets folder',
    distribution_filter: 'brand and legal sign-off before publication',
    credentials: 'zero — a grant needs its own gate, minimum surface, named expiry',
    expiration: 'this campaign',
    constraints_hard: 'no invented testimonials, statistics, or endorsements'
  }
};

function fieldsFor(tpl) {
  return TEMPLATES[tpl] || [];
}

function presetDefaults(tpl, presetName) {
  var out = {};
  var p = PRESETS[presetName];
  if (!p) { return out; }
  var fs = fieldsFor(tpl);
  for (var i = 0; i < fs.length; i++) {
    if (Object.prototype.hasOwnProperty.call(p, fs[i])) { out[fs[i]] = p[fs[i]]; }
  }
  return out;
}

function computeUnknowns(tpl, values) {
  var fs = fieldsFor(tpl);
  var unknown = [];
  for (var i = 0; i < fs.length; i++) {
    var f = fs[i];
    if (f === 'unknown_fields') { continue; }
    var v = values && values[f];
    if (v === undefined || v === null || String(v).trim() === '') { unknown.push(f); }
  }
  return unknown;
}

function compileContract(tpl, values) {
  var fs = fieldsFor(tpl);
  if (fs.length === 0) { return null; }
  var unknown = computeUnknowns(tpl, values);
  var lines = [];
  lines.push('# ' + tpl + ' — compiled request contract');
  lines.push('');
  lines.push('Compiled by psychic-sidekick from the psychic-templates vocabulary. The contract is');
  lines.push('the interface: hand this whole block to the executor.');
  lines.push('');
  lines.push('```text');
  for (var i = 0; i < fs.length; i++) {
    var f = fs[i];
    if (f === 'unknown_fields') {
      lines.push('unknown_fields: ' + (unknown.length ? unknown.join(', ') : 'none'));
      continue;
    }
    var v = values && values[f];
    var s = (v === undefined || v === null) ? '' : String(v).trim();
    lines.push(f + ': ' + (s === '' ? 'UNKNOWN' : s));
  }
  lines.push('```');
  lines.push('');
  lines.push('## Doctrine');
  lines.push('');
  lines.push(DOCTRINE);
  lines.push('');
  return lines.join('\n');
}


// SIDE-R1: the remote lane. The preamble is a SINGLE-LINE literal on purpose — the doctrine
// binding (validator section D2) extracts this line and byte-compares its decoded form against
// the fenced block in docs/REMOTE-PROMPT-PROTOCOL.md, in pure shell, formatter-safe.
var REMOTE_PREAMBLE = 'REMOTE PROMPT PROTOCOL v1 - this prompt was sent from a remote/mobile session by the operator.\nRun the request below to completion in this one turn: do not stop mid-task to ask questions.\nWhere you would normally block on a low-confidence step, proceed on the best defensible reading.\nRecord every such judgment as: ESCALATION: <what> | <why it did not block> | <what the operator must decide>.\nIrreversible or destructive actions stay forbidden without their own explicit approval - record those as escalations too.\nEnd with a summary: what was done, what was escalated, what remains.\n---\n';

// Compile a prompt pack: 'remote' wraps the contract in the protocol preamble; anything else —
// including an unknown lane — falls back to the plain local contract, never a throw.
function compilePromptPack(tpl, values, lane) {
  var contract = compileContract(tpl, values);
  if (contract === null) return null;
  if (lane === 'remote') return REMOTE_PREAMBLE + contract;
  return contract;
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    DOCTRINE: DOCTRINE, CHOICES: CHOICES, TEMPLATES: TEMPLATES, PRESETS: PRESETS,
    fieldsFor: fieldsFor, presetDefaults: presetDefaults,
    computeUnknowns: computeUnknowns, compileContract: compileContract,
    REMOTE_PREAMBLE: REMOTE_PREAMBLE, compilePromptPack: compilePromptPack
  };
}
