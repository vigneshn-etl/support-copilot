#!/usr/bin/env node
// ui-pilot bundle(s) -> utd-builder spec (and optionally the .docx).
//   node to_utd.js --after <bundle-dir> [--before <bundle-dir>] [-o spec.json] [--build] [--tested-by "Name"]
// Before-fix shots are added only when --before is given and has a shot for that case.
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

function arg(n, d) { const i = process.argv.indexOf(n); return i > -1 ? process.argv[i + 1] : d; }
const load = (dir) => JSON.parse(fs.readFileSync(path.join(dir, 'summary.json'), 'utf8'));

const afterDir = arg('--after');
if (!afterDir) { console.error('usage: to_utd.js --after <bundle> [--before <bundle>] [-o spec.json] [--build]'); process.exit(2); }
const after = load(afterDir);
const beforeDir = arg('--before');
const before = beforeDir ? load(beforeDir) : null;
const out = path.resolve(arg('-o', path.join(afterDir, '..', '..', 'utd', `${after.ticket || 'UTD'}_UTD.json`)));
const rel = (dir, p) => path.relative(path.dirname(out), path.resolve(dir, p));

// Scope: scenario fields win; missing ones come from the scope bar the UI showed.
const scope = { ...(after.scope || {}) };
if (after.scopeObserved) {
  const m = after.scopeObserved.match(/Product\s*-\s*(.*?)\s*\|\s*Location\s*-\s*(.*?)\s*(?:\|\s*(.*))?$/);
  if (m) {
    for (const [k, v] of Object.entries({ product: m[1], location: m[2], time: m[3] })) if (!scope[k] && v) scope[k] = v.trim();
  } else if (!scope.product) scope.product = after.scopeObserved;
}

const result = (s) => ({ PASS: 'PASS', FAIL: 'FAIL', ERROR: 'BLOCKED', CAPTURED: 'N/A' }[s] || s);
const cases = after.cases.map((c) => {
  const vals = c.checks.filter((x) => x.type === 'cell' || x.type === 'text');
  const b = before?.cases.find((x) => x.id === c.id);
  const shots = [];
  if (b?.shots?.length) shots.push({ label: 'Before fix', path: rel(beforeDir, b.shots[0]) });
  for (const s of c.shots) shots.push({ ...(b ? { label: 'After fix' } : {}), path: rel(afterDir, s) });
  return {
    id: c.id, module: c.module, screen: c.screen, view: c.view,
    metric: c.metric || [...new Set(vals.map((x) => x.col).filter(Boolean))].join(' / '),
    row: c.row || [...new Set(vals.map((x) => x.row).filter(Boolean))].join(' / '),
    expected: vals.length > 1 && vals.every((x) => x.expected === 'populated') ? 'populated' : vals.map((x) => x.expected).join(' / '),
    actual: c.error ? c.error : vals.map((x) => x.actual).join(' / '),
    result: result(c.status),
    shots,
  };
});

const spec = {
  ticket: after.ticket, title: after.title, client: after.client,
  tested_by: arg('--tested-by'), date: after.ranAt.slice(0, 10),
  environment: after.url.replace(/^https?:\/\//, ''), scope, cases,
};
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, JSON.stringify(spec, null, 2));
console.log(`wrote ${out}`);
if (process.argv.includes('--build'))
  execFileSync('node', [path.join(__dirname, '../utd_builder/build_utd.js'), out], { stdio: 'inherit' });
