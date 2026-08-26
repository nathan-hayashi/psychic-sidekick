// compile-test.js — behavioral proof of the compiler core. Zero dependencies; node only.
// Exits nonzero on any failure; the validator SKIPs this file only when node is absent.
var fs = require('fs');
var path = require('path');
var C = require(path.join(__dirname, '..', 'js', 'compile.js'));
var fails = 0;
function t(name, cond) {
  if (cond) { console.log('  [PASS] ' + name); }
  else { fails++; console.log('  [FAIL] ' + name); }
}

var vendor = fs.readFileSync(path.join(__dirname, '..', 'vendor', 'SCHEMA-FIELDS.txt'), 'utf8')
  .split('\n').map(function (s) { return s.trim(); }).filter(Boolean);
t('vendored vocabulary has 22 fields', vendor.length === 22);

var tplNames = Object.keys(C.TEMPLATES);
t('four templates declared', tplNames.length === 4);
var allOk = true;
tplNames.forEach(function (tpl) {
  C.TEMPLATES[tpl].forEach(function (f) {
    if (vendor.indexOf(f) === -1) { allOk = false; console.log('    undefined field ' + f + ' in ' + tpl); }
  });
});
t('every template field exists in the vendored vocabulary', allOk);

var pOk = true, rOk = true;
Object.keys(C.PRESETS).forEach(function (p) {
  Object.keys(C.PRESETS[p]).forEach(function (f) { if (vendor.indexOf(f) === -1) { pOk = false; } });
  var rc = C.PRESETS[p].risk_class;
  if (rc !== undefined && C.CHOICES.risk_class.indexOf(rc) === -1) { rOk = false; }
});
t('every preset key exists in the vendored vocabulary', pOk);
t('every preset risk_class is in the single vocabulary', rOk);

var u = C.computeUnknowns('request-contract', { goal: 'x', risk_class: 'low' });
t('blank fields land in unknown_fields', u.indexOf('completion_condition') !== -1 && u.indexOf('non_goals') !== -1);
t('filled fields stay out of unknown_fields', u.indexOf('goal') === -1 && u.indexOf('risk_class') === -1);
t('unknown_fields never lists itself', u.indexOf('unknown_fields') === -1);

var md = C.compileContract('request-contract', { goal: 'Ship the fix', risk_class: 'med' });
t('compiled output contains the doctrine verbatim', md.indexOf(C.DOCTRINE) !== -1);
t('filled field carries its value', md.indexOf('goal: Ship the fix') !== -1);
t('blank field compiles to UNKNOWN', md.indexOf('completion_condition: UNKNOWN') !== -1);
t('unknown_fields line lists the blanks', /unknown_fields: .*completion_condition/.test(md));
var md2 = C.compileContract('context-policy', { risk_class: 'high', sources_allowed: 'a',
  internal_only: 'yes', distribution_filter: 'b', credentials: 'zero', expiration: 'now' });
t('fully filled contract reads unknown_fields: none', md2.indexOf('unknown_fields: none') !== -1);
t('unknown template refuses to compile', C.compileContract('nope', {}) === null);

console.log('== compile-test: ' + (fails === 0 ? 'ALL PASS' : fails + ' FAIL') + ' ==');
process.exit(fails === 0 ? 0 : 1);
