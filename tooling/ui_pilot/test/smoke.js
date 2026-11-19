#!/usr/bin/env node
// Smoke test: pilot.js + to_utd.js against a local virtualized AG-Grid fixture. No QA access needed.
//   node test/smoke.js
const fs = require('fs');
const os = require('os');
const path = require('path');
const http = require('http');
const { spawn } = require('child_process');

// Async spawn: the fixture server lives in this process, so a sync spawn would deadlock it.
const sh = (args, env) => new Promise((resolve) => {
  const c = spawn('node', args, { env: env || process.env });
  let stdout = '', stderr = '';
  c.stdout.on('data', (d) => (stdout += d)); c.stderr.on('data', (d) => (stderr += d));
  c.on('close', (status) => resolve({ status, stdout, stderr }));
});
const assert = require('assert');

const ROOT = path.resolve(__dirname, '..');
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'ui-pilot-smoke-'));
const html = fs.readFileSync(path.join(__dirname, 'fixture.html'));

const server = http.createServer((req, res) => {
  if (req.url.startsWith('/api/pivot3/listData')) { res.writeHead(500); return res.end('{"error":"fixture pivot failure"}'); }
  if (req.url.startsWith('/api/')) { res.writeHead(200); return res.end('{}'); }
  res.writeHead(200, { 'content-type': 'text/html' }); res.end(html);
});

server.listen(0, '127.0.0.1', async () => {
  const url = `http://127.0.0.1:${server.address().port}`;
  const auth = path.join(tmp, 'auth');
  fs.mkdirSync(auth);
  fs.writeFileSync(path.join(auth, 'FIX-qa.json'), JSON.stringify({ cookies: [], origins: [] }));
  const scenario = path.join(tmp, 'scenario.yaml');
  fs.writeFileSync(scenario, `
ticket: SUP-0000
title: smoke
client: FIX
url: ${url}
cases:
  - id: TC-1
    module: Assortment Build
    screen: Style Color Review
    view: Grid View
    route: "#/a/b"
    metric: FP ST %
    expect:
      - cell: { row: "4773511150.001", col: "FP ST %", notEmpty: true }
      - cell: { row: "4773511105.001", col: "FP ST %", equals: "15.5%" }
  - id: TC-2
    screen: Write guard
    route: "#/a/c"
    steps:
      - click: Save
  - id: TC-3
    screen: Console + network
    route: "#/a/d"
    expect:
      - noConsoleErrors: true
      - noFailedRequests: true
`);
  const env = { ...process.env, UI_PILOT_AUTH_DIR: auth };
  const run = (mode, out) => sh([path.join(ROOT, 'pilot.js'), 'run', scenario, '--mode', mode, '--out', out], env);

  const repro = await run('repro', path.join(tmp, 'repro'));
  process.stdout.write(repro.stdout + repro.stderr);
  const s = JSON.parse(fs.readFileSync(path.join(tmp, 'repro', 'summary.json'), 'utf8'));
  const [tc1, tc2, tc3] = s.cases;
  assert.strictEqual(tc1.checks[0].actual, 'undefined', 'virtualized cell read (row 150, col 25)');
  assert.strictEqual(tc1.checks[0].pass, false);
  assert.strictEqual(tc1.checks[1].pass, true, 'equals check');
  assert.strictEqual(tc2.status, 'ERROR');
  assert.match(tc2.error, /blocked write-like action/);
  assert.strictEqual(tc3.checks.every((c) => !c.pass), true, 'console error + failed pivot call detected');
  assert.ok(JSON.parse(fs.readFileSync(path.join(tmp, 'repro', 'network.json'))).some((n) => n.status === 500 && n.request), 'pivot request body captured');
  assert.match(s.scopeObserved, /DP-145 ANNE KLEIN/);
  assert.strictEqual(s.verdict, 'REPRODUCED');
  assert.strictEqual(repro.status, 0);
  assert.ok(fs.existsSync(path.join(tmp, 'repro', tc1.shots[0])));

  const cap = await run('capture', path.join(tmp, 'capture'));
  assert.ok(/INCOMPLETE|CAPTURED/.test(cap.stdout));

  const utd = await sh([path.join(ROOT, 'to_utd.js'), '--after', path.join(tmp, 'repro'), '--before', path.join(tmp, 'capture'), '-o', path.join(tmp, 'utd', 'spec.json'), '--build']);
  process.stdout.write(utd.stdout + utd.stderr);
  const spec = JSON.parse(fs.readFileSync(path.join(tmp, 'utd', 'spec.json'), 'utf8'));
  assert.strictEqual(spec.scope.product, 'DP-145 ANNE KLEIN');
  assert.strictEqual(spec.cases[0].shots[0].label, 'Before fix');
  assert.ok(fs.existsSync(path.join(tmp, 'utd', 'spec.docx')));

  console.log(`\nSMOKE OK  (${tmp})`);
  server.close();
});
