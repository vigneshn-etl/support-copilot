#!/usr/bin/env node
// ui-pilot: run a ticket scenario (YAML) against the QA UI with Playwright and
// write an evidence bundle (summary.json, shots/, network.json, console.json).
//
//   node pilot.js login --client BELK [--env qa] [--manual]   # M2M token via OCI Vault (default) or human sign-in
//   node pilot.js run <scenario.yaml> --mode repro|verify|capture [--headed] [--trace] [--out dir]
//
// Exit: 0 = expected verdict (REPRODUCED / VERIFIED / CAPTURED), 1 = otherwise,
//       2 = usage/scenario error, 3 = not logged in.
const fs = require('fs');
const os = require('os');
const path = require('path');
const YAML = require('yaml');
const { chromium } = require('playwright');
const { selectFiscalWeek } = require('./vendor/calendarHelper');

const HUB = path.resolve(__dirname, '../..');
const ENVS = JSON.parse(fs.readFileSync(path.join(__dirname, 'envs.json'), 'utf8'));
const AUTH_DIR = process.env.UI_PILOT_AUTH_DIR || path.join(os.homedir(), '.ui_pilot', 'auth');

// Selectors from assortmentui/e2e-test/src/utils/selectors.ts + features/scope/scope.ts
const SEL = {
  topNav: '[data-qa="TopNav"]',
  scopeBar: '[data-qa="HeaderbarLeftSide"]', // "Product - … | Location - … | FY…" (checked on BELK QA)
  search: '[data-qa="SubheaderSearchInput"]',
  grid: '.ag-root-wrapper',
  gridLoading: '.grid-loading-overlay-container',
  overlay: '[data-qa-component="Overlay"]:not([hidden])',
  mainView: '[data-qa="CollectionViewMainView"]',
  // Scope dialog: selectors from s5-stratos/qa-automation pages/ScopePage.js
  scopeButton: 'button#Scope',
  scopeField: '.s5-MuiFormControl-root',
  asstPicker: '[data-qa="datepicker-assortmentperiod"]',
  histPicker: '[data-qa="datepicker-hindsightingperiod"]',
  pickerInput: '[data-qa="DatePickerInput"]',
  scopeSubmit: '[data-qa="button-scopeselectorsubmit"]',
  viewLoaded: 'span.fas.fa-check',
};

// Clicks/fills that persist data in QA. Blocked unless scenario sets allowWrites: true.
const WRITE_WORDS = /\b(save|submit|publish|delete|remove|plan queue|commit|approve|lock|unlock|clone|add to assortment|import|upload|reset|send)\b/i;

function die(msg, code = 2) { console.error(`ui-pilot: ${msg}`); process.exit(code); }
function arg(args, name, dflt) { const i = args.indexOf(name); return i > -1 ? args[i + 1] : dflt; }
const stamp = () => new Date().toISOString().replace(/[-:]/g, '').replace(/\..*/, '').replace('T', '-');
const norm = (s) => String(s ?? '').replace(/[\s,$]/g, '').toLowerCase();

function baseUrl(sc) {
  if (sc.url) return sc.url.replace(/\/$/, '');
  const u = ENVS[sc.client]?.[sc.env || 'qa'];
  if (!u) die(`no URL for ${sc.client}/${sc.env || 'qa'} — add it to envs.json or set url: in the scenario`);
  return u;
}
const authPath = (client, env) => path.join(AUTH_DIR, `${client}-${env || 'qa'}.json`);

// The app keeps long-lived requests open, so "load" may never fire; DOM-ready + settle() instead.
const NAV = { waitUntil: 'domcontentloaded', timeout: 120000 };

async function launch(headed) {
  // System Chrome: no Playwright browser download needed.
  return chromium.launch({ channel: 'chrome', headless: !headed });
}

// ---------- login ----------
// Default: FusionAuth M2M token, the qa-automation repo's flow (docs/auth-setup.md):
//   OCI Vault secret "<vault>-fusionauth" -> client credentials -> FusionAuth token
//   -> open BASE_URL?injectAccessToken=… once -> save the browser session.
// Needs ~/.oci/config + OCI_COMPARTMENT_ID, or ACCESS_TOKEN/ACCESS_TOKEN_EXPIRE in env.
// --manual: a human signs in in a headed window instead. Tokens are never printed or written
// except inside the saved session file (600).
const { execFileSync } = require('child_process');
const metaPath = (client, env) => authPath(client, env).replace(/\.json$/, '.meta.json');

function oci(args) {
  return execFileSync('oci', args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], timeout: 60000 }).trim();
}

async function fetchToken(client, url) {
  if (process.env.ACCESS_TOKEN && process.env.ACCESS_TOKEN_EXPIRE) return { token: process.env.ACCESS_TOKEN, expire: Number(process.env.ACCESS_TOKEN_EXPIRE) };
  const compartment = process.env.OCI_COMPARTMENT_ID;
  if (!compartment) die('set OCI_COMPARTMENT_ID (qa-automation .env / infra team) or ACCESS_TOKEN+ACCESS_TOKEN_EXPIRE, or use --manual');
  const vault = ENVS[client]?.vault;
  if (!vault) die(`no vault code for ${client} in envs.json`);
  const name = `${vault}-fusionauth`;
  console.log(`[token] OCI Vault secret "${name}"…`);
  const id = oci(['vault', 'secret', 'list', '--compartment-id', compartment, '--name', name, '--lifecycle-state', 'ACTIVE', '--all', '--query', 'data[0].id', '--raw-output']);
  if (!id || id === 'null') die(`secret "${name}" not found in that compartment`);
  const b64 = oci(['secrets', 'secret-bundle', 'get', '--secret-id', id, '--query', 'data."secret-bundle-content".content', '--raw-output']);
  const cred = JSON.parse(Buffer.from(b64, 'base64').toString('utf8'));
  const fe = await fetch(`${url}/asst/api/config/frontend`, { signal: AbortSignal.timeout(50000) }).then((r) => r.json());
  const form = new FormData();
  form.append('client_id', cred.client_entity_id);
  form.append('client_secret', cred.client_entity_secret);
  form.append('grant_type', 'client_credentials');
  form.append('audience', cred.api_entity_id);
  form.append('scope', `target-entity:${cred.api_entity_id}`);
  const res = await fetch(`${fe.auth.fusionauthUrl}/oauth2/token`, { method: 'POST', body: form, signal: AbortSignal.timeout(50000) });
  if (!res.ok) die(`FusionAuth token request failed: HTTP ${res.status}`, 1);
  const t = await res.json();
  return { token: t.access_token, expire: Math.floor(Date.now() / 1000) + t.expires_in };
}

async function saveSession(ctx, client, env, expire) {
  fs.mkdirSync(AUTH_DIR, { recursive: true, mode: 0o700 });
  const p = authPath(client, env);
  await ctx.storageState({ path: p });
  fs.chmodSync(p, 0o600);
  fs.writeFileSync(metaPath(client, env), JSON.stringify({ expire: expire || null, savedAt: new Date().toISOString() }), { mode: 0o600 });
  console.log(`session saved: ${p}${expire ? ` (expires ${new Date(expire * 1000).toISOString().slice(0, 16)}Z)` : ''}`);
}

async function login(args) {
  const client = arg(args, '--client'), env = arg(args, '--env', 'qa');
  if (!client) die('login needs --client');
  const url = baseUrl({ client, env });
  const manual = args.includes('--manual');
  const tok = manual ? null : await fetchToken(client, url);
  const browser = await launch(manual);
  const ctx = await browser.newContext({ viewport: { width: 1600, height: 900 } });
  const page = await ctx.newPage();
  const target = tok ? `${url}/?injectAccessToken=${encodeURIComponent(tok.token)}&injectAccessTokenExpire=${tok.expire}` : url;
  // QA links can be slow/flaky and SSO redirects abort the first load: retry.
  for (let i = 1; i <= 3; i++) {
    const ok = await page.goto(target, NAV).then(() => true).catch((e) => { console.log(`(attempt ${i}: ${e.message.split('\n')[0].replace(/injectAccessToken=[^&\s]+/, 'injectAccessToken=***')})`); return false; });
    if (ok || (await page.locator(SEL.topNav).count())) break;
  }
  if (manual) console.log(`Sign in to ${url} in the opened window (waiting up to 5 min)…`);
  const okNav = await page.waitForSelector(SEL.topNav, { timeout: manual ? 300000 : 120000 }).then(() => true).catch(() => false);
  if (!okNav) { await browser.close(); die('app did not load after login (no TopNav)', 1); }
  await saveSession(ctx, client, env, tok?.expire);
  await browser.close();
}

// ---------- page helpers ----------
async function settle(page) {
  await page.waitForLoadState('networkidle', { timeout: 60000 }).catch(() => {});
  await page.locator(SEL.gridLoading).first().waitFor({ state: 'hidden', timeout: 60000 }).catch(() => {});
  await page.locator(SEL.overlay).first().waitFor({ state: 'hidden', timeout: 60000 }).catch(() => {});
}

function locate(page, t) {
  if (typeof t === 'string') return page.getByText(t, { exact: false }).first();
  if (t.qa) return page.locator(`[data-qa="${t.qa}"]`).first();
  if (t.role) return page.getByRole(t.role, { name: t.name }).first();
  if (t.selector) return page.locator(t.selector).first();
  if (t.text) return page.getByText(t.text, { exact: !!t.exact }).first();
  throw new Error(`can't locate ${JSON.stringify(t)}`);
}

async function guardWrite(sc, loc, label, isFill) {
  if (sc.allowWrites) return;
  const text = (await loc.innerText().catch(() => '')) + ' ' + label;
  if (WRITE_WORDS.test(text)) throw new Error(`blocked write-like action "${text.trim().slice(0, 60)}" (set allowWrites: true after human OK)`);
  if (isFill && (await loc.evaluate((el) => !!el.closest('.ag-cell')).catch(() => false)))
    throw new Error('blocked grid cell edit (set allowWrites: true after human OK)');
}

// Scope: { product, location, assortmentWeeks: ["2027-W41", "2027-W41"], hindsightingWeeks?: [...] }
// Mirrors qa-automation ScopePage.selectDropdown / selectAssortmentFiscalWeeks.
async function setScope(page, scope, client) {
  const field = (label) => page.locator(SEL.scopeField, { hasText: label }).locator('input').first();
  if (!(await field('Product').isVisible().catch(() => false))) await page.locator(SEL.scopeButton).click();
  for (const [key, label] of [['product', 'Product'], ['location', 'Location']]) {
    if (!scope[key]) continue;
    const input = field(label);
    await input.waitFor({ state: 'visible', timeout: 60000 });
    await page.waitForFunction((el) => !el.disabled, await input.elementHandle(), { timeout: 60000 }); // disabled while scope data loads
    await input.fill('');
    await input.fill(scope[key]);
    await page.getByRole('option', { name: scope[key] }).first().click({ timeout: 60000 });
  }
  for (const [key, sel] of [['assortmentWeeks', SEL.asstPicker], ['hindsightingWeeks', SEL.histPicker]]) {
    const weeks = scope[key];
    if (!weeks) continue;
    const picker = page.locator(sel);
    await picker.locator(SEL.pickerInput).click();
    await picker.locator('.DayPicker-NavButton--prev').waitFor({ state: 'visible', timeout: 10000 });
    await selectFiscalWeek(picker, page, weeks[0], weeks[1] || weeks[0], ENVS[client]?.vault);
  }
  await page.locator(SEL.scopeSubmit).click();
  await page.locator(SEL.viewLoaded).first().waitFor({ timeout: 120000 }).catch(() => {});
  await settle(page);
}

async function runStep(page, sc, step) {
  const [kind, v] = Object.entries(step)[0];
  switch (kind) {
    case 'goto': {
      const target = baseUrl(sc) + '/' + v.replace(/^\//, '');
      if (page.url() === target) await page.goto(baseUrl(sc) + '/#/', NAV); // same hash = no reload; bounce like e2e setPageToView
      await page.goto(target, NAV);
      return settle(page);
    }
    case 'search': await page.locator(SEL.search).first().fill(String(v)); await page.keyboard.press('Enter'); return settle(page);
    case 'click': { const l = locate(page, v); await guardWrite(sc, l, typeof v === 'string' ? v : v.text || v.name || '', false); await l.click(); return settle(page); }
    case 'fill': { const l = locate(page, v); await guardWrite(sc, l, '', true); await l.fill(String(v.value)); return; }
    case 'press': await page.keyboard.press(v); return settle(page);
    case 'waitFor': await locate(page, v).waitFor({ timeout: 60000 }); return;
    case 'wait': return page.waitForTimeout(Number(v));
    case 'setScope': return setScope(page, v);
    default: throw new Error(`unknown step "${kind}"`);
  }
}

// AG Grid cell by row text + header text or col-id (UCM dataIndex). Scrolls the grid to defeat row/column virtualization.
async function readCell(page, { row, col, grid = 0 }) {
  const root = page.locator(SEL.grid).nth(grid);
  if (!(await root.count())) throw new Error('no AG Grid on screen');
  const probe = () => root.evaluate((el, a) => {
    const n = (s) => (s || '').replace(/\s+/g, ' ').trim().toLowerCase();
    const hdr = [...el.querySelectorAll('.ag-header-cell[col-id]')];
    const h = hdr.find((x) => x.getAttribute('col-id') === a.col) || hdr.find((x) => n(x.innerText) === n(a.col)) || hdr.find((x) => n(x.innerText).includes(n(a.col)));
    const seen = hdr.map((x) => `${(x.innerText || '').replace(/\s+/g, ' ').trim()}|${x.getAttribute('col-id')}`);
    const rows = [...el.querySelectorAll('.ag-row[row-index]')];
    const r = a.row === '@first' ? rows.find((x) => x.getAttribute('row-index') === '0')
      : rows.find((x) => [...x.querySelectorAll('.ag-cell')].some((c) => n(c.innerText) === n(a.row)))
      || rows.find((x) => n(x.innerText).includes(n(a.row)));
    if (!h || !r) return { col: !!h, row: !!r, seen };
    const c = el.querySelector(`.ag-row[row-index="${r.getAttribute('row-index')}"] .ag-cell[col-id="${CSS.escape(h.getAttribute('col-id'))}"]`);
    return { col: true, row: true, value: c ? c.innerText.trim() : null, rowText: [...r.querySelectorAll('.ag-cell')].map((x) => x.innerText.trim()).filter(Boolean)[0] };
  }, { row, col });
  const scroll = (sel, dx, dy) => root.evaluate((el, a) => {
    const v = el.querySelector(a.sel); if (!v) return false;
    const before = [v.scrollLeft, v.scrollTop]; v.scrollBy(a.dx, a.dy);
    return before[0] !== v.scrollLeft || before[1] !== v.scrollTop;
  }, { sel, dx, dy });

  await root.evaluate((el) => el.querySelectorAll('.ag-body-viewport,.ag-center-cols-viewport,.ag-body-horizontal-scroll-viewport').forEach((v) => { v.scrollTop = 0; v.scrollLeft = 0; }));
  const seenAll = new Set();
  for (let i = 0; i < 60; i++) {
    const p = await probe();
    (p.seen || []).forEach((x) => seenAll.add(x));
    if (p.value !== undefined) return p;
    await page.waitForTimeout(150);
    const moved = !p.row ? await scroll('.ag-body-viewport', 0, 400)
      : await scroll('.ag-body-horizontal-scroll-viewport', 500, 0) || await scroll('.ag-center-cols-viewport', 500, 0);
    if (!moved) return Promise.reject(new Error(`cell not found: row "${row}" ${p.row ? 'ok' : 'missing'}, col "${col}" ${p.col ? 'ok' : 'missing'}${p.col ? '' : ` — headers seen: ${[...seenAll].join(', ').slice(0, 1500)}`}`));
    await page.waitForTimeout(250);
  }
  throw new Error(`cell not found after scrolling: ${row} / ${col}`);
}

function compare(actual, e) {
  if ('equals' in e) return norm(actual) === norm(e.equals);
  if ('notEquals' in e) return norm(actual) !== norm(e.notEquals);
  if ('contains' in e) return norm(actual).includes(norm(e.contains));
  if ('approx' in e) { const a = parseFloat(norm(actual).replace(/%/, '')), x = parseFloat(String(e.approx).replace(/[,$%]/g, '')); return Math.abs(a - x) <= (e.tol ?? 0.05); }
  if (e.notEmpty) return norm(actual) !== '' && !/^(undefined|null|nan|-)$/.test(norm(actual));
  return true;
}
const expectedOf = (e) => e.equals ?? e.approx ?? (e.contains ? `contains ${e.contains}` : e.notEquals !== undefined ? `≠ ${e.notEquals}` : e.notEmpty ? 'populated' : '');

async function check(page, e, ctx) {
  if (e.cell) {
    const { value, rowText } = await readCell(page, e.cell);
    const row = e.cell.row === '@first' ? rowText : e.cell.row;
    return { type: 'cell', row, col: e.cell.col, expected: expectedOf(e.cell), actual: value, pass: compare(value, e.cell) };
  }
  if (e.text) {
    const visible = await page.getByText(e.text.visible ?? e.text.hidden, { exact: false }).first().isVisible().catch(() => false);
    const want = e.text.visible !== undefined;
    return { type: 'text', expected: `${want ? 'visible' : 'hidden'}: ${e.text.visible ?? e.text.hidden}`, actual: visible ? 'visible' : 'hidden', pass: visible === want };
  }
  if (e.noConsoleErrors) {
    const n = ctx.consoleErrors();
    return { type: 'console', expected: 'no console errors', actual: `${n} errors`, pass: n === 0 };
  }
  if (e.noFailedRequests) {
    const n = ctx.failedRequests();
    return { type: 'network', expected: 'no failed API calls', actual: `${n} failed`, pass: n === 0 };
  }
  throw new Error(`unknown expectation ${JSON.stringify(e)}`);
}

async function shoot(page, target, file) {
  const t = target || 'grid';
  let loc = null;
  if (t === 'grid') loc = (await page.locator(SEL.grid).count()) ? page.locator(SEL.grid).first() : null;
  else if (t === 'main') loc = page.locator(SEL.mainView).first();
  else if (t !== 'page') loc = page.locator(t.selector || t).first();
  if (loc && (await loc.isVisible().catch(() => false))) return loc.screenshot({ path: file });
  return page.screenshot({ path: file });
}

// Scope breadcrumb as the UI shows it ("Product - … | Location - … | FY…").
async function observedScope(page) {
  const t = await page.locator(SEL.scopeBar).first().innerText({ timeout: 3000 })
    .catch(() => page.getByText(/Product\s*-\s*.+Location\s*-/).first().innerText({ timeout: 3000 }))
    .catch(() => null);
  return t ? t.replace(/\s+/g, ' ').trim() : null;
}

// ---------- run ----------
async function run(args) {
  const file = args[0];
  if (!file || !fs.existsSync(file)) die('run needs <scenario.yaml>');
  const mode = arg(args, '--mode', 'verify');
  if (!['repro', 'verify', 'capture'].includes(mode)) die('--mode must be repro|verify|capture');
  const sc = YAML.parse(fs.readFileSync(file, 'utf8'));
  if (!sc.client || !Array.isArray(sc.cases)) die('scenario needs client and cases[]');
  const env = sc.env || 'qa';
  const out = path.resolve(arg(args, '--out', path.join(HUB, 'tickets', sc.ticket || 'adhoc', 'ui', `${mode}-${stamp()}`)));
  const auth = authPath(sc.client, env);
  if (!fs.existsSync(auth)) die(`not logged in — run: node pilot.js login --client ${sc.client} --env ${env}`, 3);
  const meta = fs.existsSync(metaPath(sc.client, env)) ? JSON.parse(fs.readFileSync(metaPath(sc.client, env), 'utf8')) : {};
  if (meta.expire && meta.expire - Date.now() / 1000 < 300) die(`session token expired — run: node pilot.js login --client ${sc.client} --env ${env}`, 3);

  const browser = await launch(args.includes('--headed'));
  const ctx = await browser.newContext({ storageState: auth, viewport: { width: 1600, height: 900 } });
  if (args.includes('--trace')) await ctx.tracing.start({ screenshots: true, snapshots: true });
  const page = await ctx.newPage();

  const consoleLog = [], network = [];
  let caseId = null;
  page.on('console', (m) => { if (['error', 'warning'].includes(m.type())) consoleLog.push({ case: caseId, type: m.type(), text: m.text().slice(0, 2000) }); });
  page.on('pageerror', (e) => consoleLog.push({ case: caseId, type: 'pageerror', text: String(e).slice(0, 2000) }));
  const started = new Map();
  page.on('request', (r) => started.set(r, Date.now()));
  // Rows are pushed synchronously so a check right after settle() sees them; bodies attach later.
  const record = (r, res, failure) => {
    if (!/\/api\//.test(r.url())) return;
    const status = res ? res.status() : 0;
    const row = { case: caseId, method: r.method(), url: r.url(), status, ms: Date.now() - (started.get(r) || Date.now()) };
    if (/pivot|listData/i.test(r.url()) && r.postData()) row.request = r.postData().slice(0, 4000);
    if (failure) row.error = failure;
    network.push(row);
    if (status >= 400) res.text().then((t) => { row.body = t.slice(0, 4000); }).catch(() => {});
  };
  page.on('response', (res) => record(res.request(), res));
  page.on('requestfailed', (r) => record(r, null, r.failure()?.errorText || 'failed'));

  // Auth check
  await page.goto(baseUrl(sc), NAV);
  if (!(await page.locator(SEL.topNav).waitFor({ timeout: 60000 }).then(() => true).catch(() => false))) {
    await browser.close();
    die(`session expired — run: node pilot.js login --client ${sc.client} --env ${env}`, 3);
  }
  fs.mkdirSync(path.join(out, 'shots'), { recursive: true });
  if (sc.setScope) {
    try {
      // The landing page has no scope dialog: open the module first (qa-automation openModule)
      const route = sc.setScope.route || sc.cases.find((c) => c.route)?.route;
      if (route) await runStep(page, sc, { goto: route });
      await setScope(page, sc.setScope, sc.client);
    }
    catch (e) { await page.screenshot({ path: path.join(out, 'shots', 'setScope-error.png') }).catch(() => {}); await browser.close(); die(`setScope failed: ${e.message.split('\n')[0]}`, 1); }
  }
  const scopeNow = await observedScope(page);
  if (/Product\s*-\s*null/i.test(scopeNow || '')) { await browser.close(); die('no scope selected in the app — add setScope: {product, location, assortmentWeeks} to the scenario', 2); }

  const results = [];
  for (const [i, c] of sc.cases.entries()) {
    caseId = c.id || `TC-${i + 1}`;
    const r = { id: caseId, module: c.module, screen: c.screen, view: c.view, metric: c.metric, row: c.row, checks: [], shots: [] };
    const cMark = consoleLog.length, nMark = network.length;
    const ctxFns = {
      consoleErrors: () => consoleLog.slice(cMark).filter((x) => x.type !== 'warning').length,
      failedRequests: () => network.slice(nMark).filter((x) => x.error || x.status >= 400).length,
    };
    try {
      if (c.route) await runStep(page, sc, { goto: c.route });
      for (const s of c.steps || []) await runStep(page, sc, s);
      await settle(page);
      r.url = page.url();
      r.scopeObserved = await observedScope(page);
      if (mode !== 'capture') for (const e of c.expect || []) {
        try { r.checks.push(await check(page, e, ctxFns)); }
        catch (err) { r.checks.push({ type: 'error', expected: JSON.stringify(e), actual: err.message, pass: false }); }
      }
      const shot = path.join('shots', `${caseId}.png`);
      await shoot(page, c.shot, path.join(out, shot));
      r.shots.push(shot);
      r.status = mode === 'capture' ? 'CAPTURED' : r.checks.every((x) => x.pass) ? 'PASS' : 'FAIL';
    } catch (err) {
      r.status = 'ERROR';
      r.error = err.message.split('\n')[0];
      const shot = path.join('shots', `${caseId}-error.png`);
      await page.screenshot({ path: path.join(out, shot) }).catch(() => {});
      r.shots.push(shot);
    }
    r.consoleErrors = consoleLog.slice(cMark).filter((x) => x.type !== 'warning').length;
    r.failedRequests = network.slice(nMark).filter((x) => x.error || x.status >= 400).length;
    results.push(r);
    console.log(`${caseId}  ${r.status}${r.error ? '  ' + r.error : ''}`);
  }

  if (args.includes('--trace')) await ctx.tracing.stop({ path: path.join(out, 'trace.zip') });
  await browser.close();

  const anyFail = results.some((r) => r.status === 'FAIL');
  const anyErr = results.some((r) => r.status === 'ERROR');
  const verdict = mode === 'capture' ? (anyErr ? 'INCOMPLETE' : 'CAPTURED')
    : mode === 'repro' ? (anyFail ? 'REPRODUCED' : anyErr ? 'INCOMPLETE' : 'NOT_REPRODUCED')
    : (anyFail ? 'FAILED' : anyErr ? 'INCOMPLETE' : 'VERIFIED');
  const summary = {
    ticket: sc.ticket, title: sc.title, client: sc.client, env, url: baseUrl(sc), mode, verdict,
    ranAt: new Date().toISOString(), scenario: path.resolve(file), scope: sc.scope || null,
    scopeObserved: results.find((r) => r.scopeObserved)?.scopeObserved || null,
    cases: results,
    totals: { consoleErrors: consoleLog.filter((x) => x.type !== 'warning').length, failedRequests: network.filter((x) => x.error || x.status >= 400).length, apiCalls: network.length },
  };
  fs.writeFileSync(path.join(out, 'summary.json'), JSON.stringify(summary, null, 2));
  fs.writeFileSync(path.join(out, 'console.json'), JSON.stringify(consoleLog, null, 2));
  fs.writeFileSync(path.join(out, 'network.json'), JSON.stringify(network, null, 2));
  fs.copyFileSync(file, path.join(out, 'scenario.yaml'));
  console.log(`${verdict}  →  ${out}`);
  process.exit(['REPRODUCED', 'VERIFIED', 'CAPTURED'].includes(verdict) ? 0 : 1);
}

const [cmd, ...rest] = process.argv.slice(2);
if (cmd === 'login') login(rest).catch((e) => die(e.message, 1));
else if (cmd === 'run') run(rest).catch((e) => die(e.message, 1));
else die('usage: pilot.js login --client X [--env qa] | run <scenario.yaml> --mode repro|verify|capture [--headed] [--trace] [--out dir]');
