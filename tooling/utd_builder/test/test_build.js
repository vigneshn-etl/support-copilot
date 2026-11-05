#!/usr/bin/env node
// Self-test: init from screenshots, validation, build. No network, no repo data.
//   node test/test_build.js
const fs = require('fs');
const os = require('os');
const path = require('path');
const assert = require('assert');
const { spawnSync } = require('child_process');

const CLI = path.resolve(__dirname, '..', 'build_utd.js');
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'utd-test-'));
const run = (...a) => spawnSync('node', [CLI, ...a], { encoding: 'utf8' });
const PNG = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', 'base64');

// screenshots: two shots of one screen (before/after) + one plain screen
const shots = path.join(tmp, 'in');
fs.mkdirSync(shots);
for (const f of ['01 Assortment Build - Style Color Review - Summary View (after).png',
  '01 Assortment Build - Style Color Review - Summary View (before).png',
  '02 Category Recap.png', 'notes.txt']) fs.writeFileSync(path.join(shots, f), f.endsWith('.png') ? PNG : 'x');

const spec = path.join(tmp, 'utd', 'SUP-0001_UTD.json');
let r = run('init', 'SUP-0001', '--client', 'BELK', '--shots', shots, '--out', spec);
assert.strictEqual(r.status, 0, r.stderr);
const s = JSON.parse(fs.readFileSync(spec, 'utf8'));
assert.strictEqual(s.cases.length, 2, 'one case per screen');
assert.deepStrictEqual([s.cases[0].module, s.cases[0].screen, s.cases[0].view], ['Assortment Build', 'Style Color Review', 'Summary View']);
assert.deepStrictEqual(s.cases[0].shots.map((x) => x.label), ['Before fix', 'After fix'], 'before first');
assert.strictEqual(s.cases[1].screen, 'Category Recap');
assert.strictEqual(s.cases[1].shots[0].label, undefined, 'no label without (before)/(after)');
assert.ok(fs.existsSync(path.join(tmp, 'utd', 'shots', '02 Category Recap.png')), 'shots copied');
assert.notStrictEqual(run('init', 'SUP-0001', '--out', spec).status, 0, 'init never overwrites');

// unfilled skeleton: builds, but warns
r = run(spec, '--check');
assert.strictEqual(r.status, 0);
assert.match(r.stdout, /warn: scope\.product not filled/);
assert.match(r.stdout, /warn: TC-1: metric not filled/);

// filled: clean check, docx written
Object.assign(s, { title: 't', environment: 'qa.belk.oci.s5stratos.com', scope: { product: 'DP-1', location: 'Belk', time: 'FY27-W41' } });
s.cases.forEach((c) => Object.assign(c, { metric: 'ST %', row: 'Style 1', expected: '5.4%', actual: '5.4%', result: 'PASS' }));
fs.writeFileSync(spec, JSON.stringify(s));
r = run(spec, '--check');
assert.match(r.stdout, /check: ok/, r.stdout);
r = run(spec);
assert.strictEqual(r.status, 0, r.stderr);
assert.ok(fs.statSync(spec.replace(/\.json$/, '.docx')).size > 1000, 'docx written');

// hard errors stop the build
const bad = path.join(tmp, 'bad.json');
fs.writeFileSync(bad, JSON.stringify({ cases: [{ metric: 'x' }] }));
r = run(bad);
assert.strictEqual(r.status, 1);
assert.match(r.stderr, /ticket is missing/);
assert.match(r.stderr, /TC-1: screen\/view missing/);

console.log(`UTD TEST OK  (${tmp})`);
