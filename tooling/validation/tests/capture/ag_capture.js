// DVS: capture a QA AG Grid as a regression-case "expected" block (run in the QA page).
// Usage: paste, then __dvsCapture({key: "stylecolor", cols, level: "stylecolor"}) -> JSON string.
// level: keep only rows at that hierarchy level (nested grids carry member:<level>:id on deeper rows).
// Checksums per column: [sum, key-weighted sum, non-zero count]; weight = key_weight() in validate.py.
window.__dvsCapture = (opt = {}) => {
  const el = document.querySelector('.ag-root-wrapper');
  let api = null;
  for (const k of Object.keys(el).filter(k => /react|ag/i.test(k))) {
    let f = el[k];
    for (let i = 0; i < 40 && f && !api; i++) {
      const p = f.memoizedProps || f.pendingProps;
      api = (p && p.api) || (f.stateNode && f.stateNode.api) || null;
      f = f.return;
    }
    if (api) break;
  }
  if (!api) return JSON.stringify({error: 'no AG Grid api'});
  const rows = [];
  api.forEachNode(n => { if (n.data && !n.group) rows.push(n.data); });
  if (opt.level) rows.splice(0, rows.length, ...rows.filter(r => `member:${opt.level}:id` in r));
  const key = opt.key || 'stylecolor';
  const w = s => { let x = 0; for (const ch of String(s)) x = (x * 31 + ch.charCodeAt(0)) % 9973; return x % 97 + 1; };
  const skip = c => c === key || c.includes(':') || c.endsWith('_band_color') || /^g_|^id$/.test(c);
  const cols = (opt.cols || Object.keys(rows[0] || {})).filter(c => !skip(c) && rows.some(r => typeof r[c] === 'number'));
  const sig = v => +(+v).toPrecision(8);
  const out = {n_rows: rows.length, key, cols: {}};
  for (const c of cols) {
    let s1 = 0, s2 = 0, nz = 0;
    for (const r of rows) { const v = +r[c] || 0; s1 += v; s2 += v * w(r[key]); if (v) nz++; }
    out.cols[c] = [sig(s1), sig(s2), nz];
  }
  if (opt.totals) {   // pinned rollup row(s)
    const t = {};
    (api.getPinnedTopRowCount ? [...Array(api.getPinnedTopRowCount()).keys()].map(i => api.getPinnedTopRow(i)) : [])
      .forEach(n => Object.entries(n.data || {}).forEach(([c, v]) => { if (typeof v === 'number') t[c] = v; }));
    out.pinned = t;
  }
  return JSON.stringify(out);
};
