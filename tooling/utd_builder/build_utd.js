#!/usr/bin/env node
// Unit Test Document builder: JSON spec -> .docx (minimal, screenshot-first).
// Usage: node build_utd.js <spec.json> [-o out.docx] [--check]
//        node build_utd.js init <SUP-ID> --client <C> [--shots <dir>] [--title "…"] [--out spec.json]
// Spec contract: see README.md. Image paths resolve relative to the spec file.
const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, ImageRun, Table, TableRow, TableCell,
  WidthType, ShadingType, AlignmentType, BorderStyle, HeadingLevel, PageBreak,
} = require('docx');

const NAVY = '1F3864', GREY = '666666', LIGHT = 'F2F2F2', LINE = 'BFBFBF';
const RESULT_COLOR = { PASS: '1E7B34', FAIL: 'C00000', ISSUE: 'C55A11', BLOCKED: 'B26B00', 'N/A': GREY, INFO: GREY };
const PAGE_W = 12240, MARGIN = 1080, CONTENT_W = PAGE_W - 2 * MARGIN; // US Letter, 0.75in margins
const FONT = 'Calibri';

const border = { style: BorderStyle.SINGLE, size: 4, color: LINE };
const borders = { top: border, bottom: border, left: border, right: border };

function run(text, o = {}) {
  return new TextRun({ text: String(text ?? ''), font: FONT, size: o.size || 20, bold: o.bold, color: o.color, italics: o.italics });
}

function cell(text, width, o = {}) {
  return new TableCell({
    borders,
    width: { size: width, type: WidthType.DXA },
    shading: o.fill ? { fill: o.fill, type: ShadingType.CLEAR, color: 'auto' } : undefined,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: [new Paragraph({ alignment: o.align, children: [run(text, o)] })],
  });
}

function table(widths, rows) {
  return new Table({ width: { size: CONTENT_W, type: WidthType.DXA }, columnWidths: widths, rows });
}

// PNG/JPEG pixel size without extra deps.
function imageSize(buf) {
  if (buf.readUInt32BE(0) === 0x89504e47) return { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20), type: 'png' };
  if (buf[0] === 0xff && buf[1] === 0xd8) {
    let i = 2;
    while (i < buf.length) {
      const marker = buf[i + 1], len = buf.readUInt16BE(i + 2);
      if (marker >= 0xc0 && marker <= 0xcf && ![0xc4, 0xc8, 0xcc].includes(marker))
        return { w: buf.readUInt16BE(i + 7), h: buf.readUInt16BE(i + 5), type: 'jpg' };
      i += 2 + len;
    }
  }
  throw new Error('unsupported image (png/jpg only)');
}

function screenshot(file, baseDir) {
  const p = path.resolve(baseDir, file);
  if (!fs.existsSync(p)) {
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      border: { top: border, bottom: border, left: border, right: border },
      spacing: { before: 80, after: 80 },
      children: [run(`[ screenshot: ${file} ]`, { color: GREY, italics: true })],
    });
  }
  const data = fs.readFileSync(p);
  const { w, h, type } = imageSize(data);
  const maxW = 624; // 6.5in at 96dpi
  const width = Math.min(maxW, w), height = Math.round((h * width) / w);
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    children: [new ImageRun({ type, data, transformation: { width, height }, altText: { title: path.basename(p), description: path.basename(p), name: path.basename(p) } })],
  });
}

function screenPath(c) {
  return [c.module, c.screen, c.view].filter(Boolean).join(' › ');
}

function build(spec, baseDir) {
  const s = spec.scope || {};
  const body = [];

  body.push(new Paragraph({ heading: HeadingLevel.TITLE, children: [run(`${spec.ticket} — Unit Test Document`, { size: 32, bold: true, color: NAVY })] }));
  if (spec.title) body.push(new Paragraph({ spacing: { after: 60 }, children: [run(spec.title, { color: GREY })] }));
  const meta = [spec.client, spec.tested_by, spec.date].filter(Boolean).join('  ·  ');
  if (meta) body.push(new Paragraph({ spacing: { after: 200 }, children: [run(meta, { size: 18, color: GREY })] }));

  // Scope
  body.push(new Paragraph({ heading: HeadingLevel.HEADING_1, spacing: { before: 120, after: 80 }, children: [run('Test Scope', { size: 24, bold: true, color: NAVY })] }));
  const scopeRows = [
    ['Environment', spec.environment],
    ['Product Scope', s.product],
    ['Location Scope', s.location],
    ['Time Scope', s.time],
    ['Filters', s.filters],
  ].filter(([, v]) => v);
  const sw = [2200, CONTENT_W - 2200];
  body.push(table(sw, scopeRows.map(([k, v]) => new TableRow({ children: [cell(k, sw[0], { bold: true, fill: LIGHT }), cell(v, sw[1])] }))));

  // Results summary
  body.push(new Paragraph({ heading: HeadingLevel.HEADING_1, spacing: { before: 240, after: 80 }, children: [run('Results', { size: 24, bold: true, color: NAVY })] }));
  const rw = [700, 3260, 1900, 1300, 1300, 1620];
  const head = ['#', 'Screen', 'Metric / Column', 'Expected', 'Actual', 'Result'];
  const rows = [new TableRow({ tableHeader: true, children: head.map((h, i) => cell(h, rw[i], { bold: true, color: 'FFFFFF', fill: NAVY, size: 18 })) })];
  spec.cases.forEach((c, i) => {
    const res = (c.result || '').toUpperCase();
    rows.push(new TableRow({ children: [
      cell(c.id || `TC-${i + 1}`, rw[0], { size: 18 }),
      cell(screenPath(c), rw[1], { size: 18 }),
      cell(c.metric, rw[2], { size: 18 }),
      cell(c.expected, rw[3], { size: 18 }),
      cell(c.actual, rw[4], { size: 18 }),
      cell(res, rw[5], { size: 18, bold: true, color: RESULT_COLOR[res] || '000000', align: AlignmentType.CENTER }),
    ] }));
  });
  body.push(table(rw, rows));

  // Per-case evidence
  spec.cases.forEach((c, i) => {
    if (spec.evidence_only_with_shots && !(c.shots || []).length) return; // SUP-4648: large sweeps - pages only for cases with screenshots
    body.push(new Paragraph({ children: [new PageBreak()] }));
    body.push(new Paragraph({ heading: HeadingLevel.HEADING_2, spacing: { after: 60 }, children: [run(`${c.id || `TC-${i + 1}`}  ·  ${screenPath(c)}`, { size: 22, bold: true, color: NAVY })] }));
    const facts = [['Metric', c.metric], ['Row', c.row], ['Scope', c.scope]].filter(([, v]) => v);
    body.push(new Paragraph({ spacing: { after: 120 }, children: facts.flatMap(([k, v], j) => [
      ...(j ? [run('   |   ', { color: LINE })] : []), run(`${k}: `, { bold: true, size: 18 }), run(v, { size: 18 }),
    ]) }));
    (c.shots || []).forEach((shot) => {
      if (shot.label) body.push(new Paragraph({ spacing: { before: 120, after: 40 }, children: [run(shot.label, { size: 18, bold: true, color: GREY })] }));
      body.push(screenshot(shot.path, baseDir));
    });
  });

  return new Document({
    styles: { default: { document: { run: { font: FONT, size: 20 } } } },
    sections: [{ properties: { page: { size: { width: PAGE_W, height: 15840 }, margin: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN } } }, children: body }],
  });
}

// ---------- validation ----------
const PLACEHOLDER = /^<.*>$/;
const IMG = /\.(png|jpe?g)$/i;

function validate(spec, baseDir) {
  const errors = [], warnings = [];
  const filled = (v) => v !== undefined && v !== null && String(v).trim() !== '' && !PLACEHOLDER.test(String(v).trim());
  if (!filled(spec.ticket)) errors.push('ticket is missing');
  if (!Array.isArray(spec.cases) || !spec.cases.length) errors.push('cases[] is empty');
  for (const k of ['product', 'location', 'time']) if (!filled(spec.scope?.[k])) warnings.push(`scope.${k} not filled`);
  if (!filled(spec.environment)) warnings.push('environment not filled');
  (spec.cases || []).forEach((c, i) => {
    const id = c.id || `TC-${i + 1}`;
    if (!c.screen && !c.view) errors.push(`${id}: screen/view missing`);
    else if (!filled(c.screen) && !filled(c.view)) warnings.push(`${id}: screen not filled`);
    for (const k of ['metric', 'expected', 'actual']) if (!filled(c[k])) warnings.push(`${id}: ${k} not filled`);
    if (!RESULT_COLOR[(c.result || '').toUpperCase()]) warnings.push(`${id}: result "${c.result || ''}" not one of ${Object.keys(RESULT_COLOR).join('/')}`);
    for (const sh of c.shots || []) {
      if (!fs.existsSync(path.resolve(baseDir, sh.path))) warnings.push(`${id}: screenshot not found: ${sh.path}`);
      else if (!IMG.test(sh.path)) errors.push(`${id}: ${sh.path} is not png/jpg`);
    }
  });
  return { errors, warnings };
}

// ---------- init: spec skeleton from a folder of screenshots ----------
// File name -> screen path: "02 Assortment Build - Style Color Review - Summary View (after).png"
//   leading number = order, " - " / " > " / "›" / "__" split module/screen/view,
//   "(before)" / "(after)" = Before/After fix shot of the same case.
function initSpec(args) {
  const arg = (n, d) => { const i = args.indexOf(n); return i > -1 ? args[i + 1] : d; };
  const ticket = args[1];
  if (!ticket || ticket.startsWith('-')) { console.error('usage: build_utd.js init <SUP-ID> --client <C> [--shots <dir>] [--title "…"] [--out spec.json]'); process.exit(2); }
  const hub = path.resolve(__dirname, '../..');
  const out = path.resolve(arg('--out', path.join(hub, 'tickets', ticket, 'utd', `${ticket}_UTD.json`)));
  if (fs.existsSync(out)) { console.error(`exists, not overwriting: ${out}`); process.exit(2); }
  const shotsDir = path.join(path.dirname(out), 'shots');
  const cases = new Map();
  const src = arg('--shots');
  if (src) {
    const files = fs.readdirSync(src).filter((f) => IMG.test(f)).sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
    if (!files.length) { console.error(`no png/jpg in ${src}`); process.exit(2); }
    fs.mkdirSync(shotsDir, { recursive: true });
    for (const f of files) {
      let name = f.replace(IMG, '').replace(/^\s*(tc[-_ ]?)?\d+[\s._-]*/i, '');
      const tag = (name.match(/\((before|after)[^)]*\)\s*$/i) || [])[1];
      name = name.replace(/\((before|after)[^)]*\)\s*$/i, '').trim();
      const parts = name.split(/\s+-\s+|\s*[>›]\s*|__/).map((x) => x.trim()).filter(Boolean);
      const key = parts.join(' › ').toLowerCase() || f;
      if (!cases.has(key)) {
        const [module, screen, view] = parts.length >= 3 ? parts : parts.length === 2 ? [undefined, ...parts] : [undefined, parts[0] || f, undefined];
        cases.set(key, { module, screen, view, metric: '<metric / column>', row: '<row checked>', expected: '<expected>', actual: '<actual>', result: '<PASS|FAIL>', shots: [] });
      }
      fs.copyFileSync(path.join(src, f), path.join(shotsDir, f));
      const label = tag ? (tag.toLowerCase() === 'before' ? 'Before fix' : 'After fix') : undefined;
      const shot = { ...(label ? { label } : {}), path: `shots/${f}` };
      const list = cases.get(key).shots;
      if (label === 'Before fix') list.unshift(shot); else list.push(shot);
    }
  } else {
    cases.set('tc', { module: '<Module>', screen: '<Screen>', view: '<View / Tab>', metric: '<metric / column>', row: '<row checked>', expected: '<expected>', actual: '<actual>', result: '<PASS|FAIL>', shots: [] });
  }
  const spec = {
    ticket, title: arg('--title', '<JIRA summary>'), client: arg('--client', '<CLIENT>'), tested_by: arg('--tested-by', '<name>'),
    date: new Date().toISOString().slice(0, 10), environment: arg('--env-url', '<qa.client.oci.s5stratos.com>'),
    scope: { product: '<product scope>', location: '<location scope>', time: '<time scope>' },
    cases: [...cases.values()].map((c, i) => ({ id: `TC-${i + 1}`, ...c })),
  };
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, JSON.stringify(spec, null, 2));
  console.log(`wrote ${out} (${spec.cases.length} case${spec.cases.length > 1 ? 's' : ''}) — fill the <…> fields, then: node build_utd.js ${path.relative(process.cwd(), out)}`);
}

if (require.main === module) {
  const args = process.argv.slice(2);
  if (args[0] === 'init') { initSpec(args); return; }
  const specPath = args[0];
  if (!specPath) { console.error('usage: build_utd.js <spec.json> [-o out.docx] [--check] | init <SUP-ID> --client <C> [--shots <dir>]'); process.exit(2); }
  const spec = JSON.parse(fs.readFileSync(specPath, 'utf8'));
  const baseDir = path.dirname(path.resolve(specPath));
  const { errors, warnings } = validate(spec, baseDir);
  warnings.forEach((w) => console.log(`warn: ${w}`));
  errors.forEach((e) => console.error(`error: ${e}`));
  if (errors.length) process.exit(1);
  if (args.includes('--check')) { console.log(warnings.length ? `check: ${warnings.length} warning(s)` : 'check: ok'); return; }
  const oi = args.indexOf('-o');
  const out = oi > -1 ? args[oi + 1] : specPath.replace(/\.json$/, '.docx');
  Packer.toBuffer(build(spec, baseDir)).then((buf) => {
    fs.writeFileSync(out, buf);
    console.log(`wrote ${out}`);
  });
}

module.exports = { build, validate };
