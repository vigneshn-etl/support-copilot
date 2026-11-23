// Spec editor + screen coverage for the Data Validation Studio.
// Uses globals from index.html: $, api, esc, S, META, store, fmtN.
const SPEC={data:null,meta:null,file:'metrics',sel:null,isNew:false};
const FILES=[
  ['metrics','Metrics','what screens show'],['measures','Measures','one aggregate on one table'],
  ['populations','Population rules','which items are in'],['screens','Screens','data call → population'],
  ['bindings','Bindings','screen column → metric'],['sources','Sources','fact tables']];
const LABEL_COL={metrics:'label',measures:'label',populations:'rule_id',screens:'pivot',bindings:'label',sources:'description'};
const me=()=>{const v=($('me')||{}).textContent;return v||'';};

// ---------- field definitions (form layout per file)
const F={
 metrics:[['metric_id','Metric id','key','lowercase id; screens bind to it (usually the dataIndex)'],['label','Label','text'],
   ['type','Type','select:metric_types'],['expr','Formula / numerator','formula','use measure and metric ids, e.g. shp_r - ret_r'],
   ['denominator','Denominator','formula','ratio only; the value is 0 when the denominator ≤ 0'],['round','Round to decimals','text','e.g. 4 (ratios)'],['notes','Notes / requirement','area','paste the ticket formula or rule here']],
 measures:[['measure_id','Measure id','key'],['label','Label','text'],['source_id','Source table','select:sources'],
   ['expr','Column or expression','column','a column of the source table, e.g. shp_u'],['agg','Aggregation','select:aggs'],
   ['filter','Row filter','column','optional, e.g. prodlife = \'FP\' or strcntwk > 0'],['time_window','Weeks','select:windows'],
   ['location_set','Locations','select:location_sets'],['rollup','Roll up across items','select:rollups'],['notes','Notes','area']],
 populations:[['population_id','Population id','text'],['step','Step','text'],['rule_id','Rule id','key2'],['kind','Kind','select:rule_kinds'],
   ['source_id','Source table','select:sources'],['time_window','Weeks','select:windows'],['condition','Condition','formula','having: aggregate test; classify: class expression; combine: rule ids with AND / OR'],
   ['row_filter','Row filter','formula'],['applies_when','Applies when','text','e.g. FP in price_status'],['notes','Notes','area']],
 screens:[['pivot','Data call (pivot)','key'],['population_id','Population','select:populations'],['time_mode','Weeks from','select:time_modes'],
   ['split_by_class','Rows split by class','select:yesno'],['notes','Notes','area']],
 bindings:[['pivot','Data call','key'],['viewdefn','Section (viewdefn)','key2'],['data_index','Column dataIndex','key3'],['label','Screen label','text'],
   ['metric_id','Spec metric','metric'],['rollup_formula','Screen rollup formula','formula','how the screen totals this column, e.g. sum(net_sls_r) or sum(1)'],['notes','Notes','area']],
 sources:[['source_id','Source id','key'],['table','ClickHouse table','text'],['item_key','Item key','text'],['location_key','Location key','text'],
   ['time_key','Time key','text'],['level_filters','Level filters applied','text','e.g. prodlife,cluster'],['description','Description','area']],
};
const OPTS=()=>({...SPEC.meta,sources:Object.keys(SPEC.meta.sources).map(id=>({id,help:SPEC.meta.sources[id].table})),
  populations:SPEC.meta.populations.map(id=>({id})),time_modes:[{id:'history'},{id:'assortment'}],yesno:[{id:'yes'},{id:'no'}]});

// ---------- tabs
function showView(v){document.querySelectorAll('#toptabs button').forEach(b=>b.classList.toggle('on',b.dataset.v===v));
  document.querySelectorAll('.view').forEach(x=>x.classList.toggle('on',x.id==='v_'+v));
  store.set('view',v); if(v==='spec')loadSpec(); if(v==='cov')drawCoverage(); if(v==='sync')syncStatus();}
document.querySelectorAll('#toptabs button').forEach(b=>b.onclick=()=>showView(b.dataset.v));

// ---------- load
async function loadSpec(keepSel){
  [SPEC.data,SPEC.meta]=await Promise.all([api('/api/v2/spec'),api('/api/v2/spec/meta')]);
  if($('me')&&!$('me').textContent)$('me').textContent=SPEC.meta.user;
  drawRail();drawTable();if(!keepSel)drawDrawer();
}
function rowsOf(f){return (SPEC.data.files[f]||{rows:[]}).rows;}
function keyOf(f,r){return SPEC.data.files[f].keys.map(k=>r[k]).join('|');}
function lintFor(f,k){return SPEC.data.lint.filter(i=>i.file===f&&(i.key===k||i.key===k.split('|').pop()||k.split('|').join('.').endsWith(i.key)));}

function drawRail(){
  const lintCount=f=>SPEC.data.lint.filter(i=>i.file===f&&i.level==='error').length;
  $('rail').innerHTML=FILES.map(([f,t,h])=>`<button data-f="${f}" class="${SPEC.file===f?'on':''}" title="${esc(h)}"><span>${t}${lintCount(f)?' <span class="st retired">'+lintCount(f)+'</span>':''}</span><span class="n">${rowsOf(f).length}</span></button>`).join('')+
    `<hr/><button data-f="changelog" class="${SPEC.file==='changelog'?'on':''}"><span>Changelog</span><span class="n">↺</span></button>`;
  $('rail').querySelectorAll('button').forEach(b=>b.onclick=()=>{SPEC.file=b.dataset.f;SPEC.sel=null;SPEC.isNew=false;drawRail();drawTable();drawDrawer();});
}

// ---------- table
const TCOLS={
 metrics:r=>[`<code>${esc(r.metric_id)}</code>`,esc(r.label),esc(r.type),`<code>${esc(SPEC.data.expanded[r.metric_id]||'')}</code>`,(SPEC.data.used_by[r.metric_id]||[]).length||''],
 measures:r=>[`<code>${esc(r.measure_id)}</code>`,esc(r.label),`${esc(r.agg)}(<code>${esc(r.expr)}</code>)${r.filter?` <span class="muted">where</span> <code>${esc(r.filter)}</code>`:''}`,esc(r.source_id)+' · '+esc(r.time_window),esc(r.rollup)],
 populations:r=>[`<code>${esc(r.population_id)}.${esc(r.rule_id)}</code>`,esc(r.kind),`<code>${esc(r.condition||r.row_filter)}</code>`,esc(r.source_id)+(r.time_window?' · '+esc(r.time_window):''),esc(r.applies_when)],
 screens:r=>[`<code>${esc(r.pivot)}</code>`,esc(r.population_id),esc(r.time_mode),esc(r.split_by_class),esc(r.notes)],
 bindings:r=>[esc(r.viewdefn),esc(r.label),`<code>${esc(r.data_index)}</code>`,r.metric_id?`<code>${esc(r.metric_id)}</code>`:'<span class="muted">—</span>',`<code>${esc(r.rollup_formula)}</code>`],
 sources:r=>[`<code>${esc(r.source_id)}</code>`,`<code>${esc(r.table)}</code>`,esc([r.item_key,r.location_key,r.time_key].filter(Boolean).join(' · ')),esc(r.level_filters),esc(r.description)],
};
const THEAD={metrics:['Id','Label','Type','Formula (base columns)','Used'],measures:['Id','Label','Aggregate','Source · weeks','Roll-up'],
  populations:['Rule','Kind','Condition','Source · weeks','Applies when'],screens:['Data call','Population','Weeks','Split','Notes'],
  bindings:['Section','Label','dataIndex','Metric','Rollup formula'],sources:['Id','Table','Keys','Level filters','Description']};
function drawTable(){
  const f=SPEC.file;
  if(f==='changelog'){$('sp_title').textContent='Changelog';$('sp_new').style.display='none';
    api('/api/v2/spec/changelog').then(rows=>{$('sp_table').innerHTML=rows.length?`<table class="e"><tr><th>When</th><th>Who</th><th>What</th><th>Action</th><th>v</th></tr>${rows.map(r=>`<tr><td>${esc(r.ts.replace('T',' '))}</td><td>${esc(r.user)}</td><td>${esc(r.file)} · <code>${esc(r.key)}</code></td><td>${esc(r.action)}</td><td>${esc(r.version)}</td></tr>`).join('')}</table>`:'<div class="muted">No changes yet.</div>';});
    $('sp_lint').innerHTML='';return;}
  $('sp_new').style.display='';$('sp_title').textContent=FILES.find(x=>x[0]===f)[1];
  const q=($('sp_q').value||'').toLowerCase(), st=$('sp_st').value;
  const rows=rowsOf(f).filter(r=>(!st||(r.status||'')===st)&&(!q||JSON.stringify(r).toLowerCase().includes(q)||(SPEC.data.expanded[r.metric_id]||'').toLowerCase().includes(q)));
  $('sp_table').innerHTML=`<table class="e"><tr>${THEAD[f].map(h=>`<th>${h}</th>`).join('')}<th>Status</th></tr>${rows.map(r=>{const k=keyOf(f,r);
    const errs=lintFor(f,k).filter(i=>i.level==='error').length;
    return `<tr class="row ${SPEC.sel===k?'sel':''}" data-k="${esc(k)}">${TCOLS[f](r).map(c=>`<td>${c}</td>`).join('')}<td><span class="st ${esc(r.status)}">${esc(r.status)}${r.version?' v'+esc(r.version):''}</span>${errs?' <span class="st retired" title="lint errors">!</span>':''}</td></tr>`;}).join('')}</table>`+
    (rows.length?'':'<div class="muted" style="padding:10px">nothing matches</div>');
  $('sp_table').querySelectorAll('tr.row').forEach(tr=>tr.onclick=()=>{SPEC.sel=tr.dataset.k;SPEC.isNew=false;drawTable();drawDrawer();});
  const errs=SPEC.data.lint.filter(i=>i.file===f);
  $('sp_lint').innerHTML=errs.length?`<details><summary class="muted" style="cursor:pointer">${errs.length} lint note(s) in ${esc(f)}</summary>${errs.slice(0,60).map(i=>`<div class="lintmsg ${i.level}">${esc(i.key)}: ${esc(i.msg)}</div>`).join('')}</details>`:'<div class="muted">✓ no lint issues</div>';
}
$('sp_q').oninput=drawTable;$('sp_st').onchange=drawTable;
$('sp_new').onclick=()=>{SPEC.sel=null;SPEC.isNew=true;drawTable();drawDrawer({});};

// ---------- drawer (form)
function drawDrawer(prefill){
  const f=SPEC.file,d=$('drawer');
  if(f==='changelog'||(!SPEC.sel&&!SPEC.isNew)){d.innerHTML='<div class="muted">Select a row to view or edit it, or press <b>+ New</b>.</div>';return;}
  const row=SPEC.isNew?(prefill||{}):rowsOf(f).find(r=>keyOf(f,r)===SPEC.sel)||{};
  const o=OPTS();
  const names=SPEC.meta.names;
  const srcCols=()=>{const sid=(d.querySelector('[name=source_id]')||{}).value||row.source_id;return ((SPEC.meta.sources[sid]||{}).columns)||[];};
  const fld=([n,lbl,kind,help])=>{
    const v=esc(row[n]??'');const ro=(!SPEC.isNew&&kind.startsWith('key'))?'readonly':'';
    let input;
    if(kind.startsWith('select:')){const opts=o[kind.slice(7)]||[];
      input=`<select name="${n}">${opts.map(x=>`<option value="${esc(x.id)}" ${x.id===row[n]?'selected':''} title="${esc(x.help||'')}">${esc(x.id)}${x.help?' — '+esc(x.help):''}</option>`).join('')}</select>`;}
    else if(kind==='area')input=`<textarea name="${n}" rows="3">${v}</textarea>`;
    else if(kind==='formula')input=`<input name="${n}" class="mono" value="${v}" list="dl_names" autocomplete="off"/>`;
    else if(kind==='metric')input=`<input name="${n}" class="mono" value="${v}" list="dl_metrics" autocomplete="off"/>`;
    else if(kind==='column')input=`<input name="${n}" class="mono" value="${v}" list="dl_cols" autocomplete="off"/>`;
    else input=`<input name="${n}" class="${kind.startsWith('key')?'mono':''}" value="${v}" ${ro}/>`;
    return `<div class="fld" data-f="${n}"><label>${esc(lbl)}</label>${input}${help?`<div class="help">${esc(help)}</div>`:''}</div>`;};
  const k=SPEC.isNew?'':SPEC.sel;
  const lint=k?lintFor(f,k):[];
  const used=f==='metrics'&&row.metric_id?(SPEC.data.used_by[row.metric_id]||[]):[];
  d.innerHTML=`<h3 style="margin:0 0 10px;font-size:14px">${SPEC.isNew?'New '+esc(FILES.find(x=>x[0]===f)[1].replace(/s$/,'')).toLowerCase():esc(row[LABEL_COL[f]]||k)}
      ${row.status?` <span class="st ${esc(row.status)}">${esc(row.status)} v${esc(row.version||'')}</span>`:''}</h3>
    ${row.approved_by?`<div class="muted" style="margin:-6px 0 8px">approved by ${esc(row.approved_by)} on ${esc(row.approved_at)}</div>`:''}
    <form id="sp_form">${F[f].map(fld).join('')}</form>
    <datalist id="dl_names">${names.map(n=>`<option value="${esc(n)}">`).join('')}</datalist>
    <datalist id="dl_metrics">${rowsOf('metrics').map(r=>`<option value="${esc(r.metric_id)}">${esc(r.label)}</option>`).join('')}</datalist>
    <datalist id="dl_cols"></datalist>
    ${(f==='metrics'||f==='measures')&&!SPEC.isNew?`<div class="lbl">Reads as</div><div class="reads">${esc(SPEC.data.expanded[row.metric_id||row.measure_id]||'')}</div>`:''}
    ${used.length?`<div class="lbl" style="margin-top:8px">Used on screens (${used.length})</div><div class="muted" style="font-size:12px">${used.slice(0,8).map(esc).join('<br/>')}${used.length>8?'<br/>…':''}</div>`:''}
    <div id="sp_msgs" style="margin-top:8px">${lint.map(i=>`<div class="lintmsg ${i.level}">• ${esc(i.msg)}</div>`).join('')}</div>
    <div class="acts">
      <button class="btn p" id="sp_save">${SPEC.isNew?'Add as draft':'Save (new version → draft)'}</button>
      ${!SPEC.isNew&&row.status!=='approved'?`<button class="btn" id="sp_appr" title="Approve as ${esc(me())}">✓ Approve</button>`:''}
      ${!SPEC.isNew&&row.status!=='retired'?`<button class="btn" id="sp_ret">Retire</button>`:''}
      ${f==='metrics'&&!SPEC.isNew?`<button class="btn" id="sp_prev" title="Compute this metric for the current scope">Preview on scope</button>`:''}
    </div><div id="sp_prevout"></div>`;
  const syncCols=()=>{$('dl_cols').innerHTML=srcCols().map(c=>`<option value="${esc(c)}">`).join('');};
  syncCols();const ss=d.querySelector('[name=source_id]');if(ss)ss.onchange=syncCols;
  const ty=d.querySelector('[name=type]');const den=d.querySelector('[data-f=denominator]');
  const showDen=()=>{if(ty&&den)den.style.display=ty.value==='ratio'?'':'none';};if(ty){ty.onchange=showDen;showDen();}
  const formRow=()=>{const o={};new FormData($('sp_form')).forEach((v,k)=>o[k]=v.trim());return o;};
  $('sp_save').onclick=async()=>{
    try{const r=await api(`/api/v2/spec/${f}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({row:formRow(),user:me(),base_version:SPEC.isNew?null:row.version})});
      SPEC.sel=keyOf2(f,r.row);SPEC.isNew=false;await loadSpec(true);drawTable();drawDrawer();
      $('sp_msgs').innerHTML='<div class="lintmsg" style="color:var(--ok)">✓ saved as draft — approve it to make it the validation rule</div>';
      afterSpecChange&&afterSpecChange();}
    catch(e){const l=(e&&e.lint)||null;$('sp_msgs').innerHTML=l?l.map(i=>`<div class="lintmsg error">• ${esc(i.msg)}</div>`).join(''):`<div class="lintmsg error">• ${esc(typeof e==='string'?e:JSON.stringify(e))}</div>`;}};
  const setSt=async st=>{await api(`/api/v2/spec/${f}/status`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({key:row,status:st,user:me()})});
    await loadSpec(true);drawTable();drawDrawer();afterSpecChange&&afterSpecChange();};
  if($('sp_appr'))$('sp_appr').onclick=()=>setSt('approved');
  if($('sp_ret'))$('sp_ret').onclick=()=>{if(confirm('Retire this row? It stops being used for validation (history is kept).'))setSt('retired');};
  if($('sp_prev'))$('sp_prev').onclick=()=>previewMetric(row);
}
function keyOf2(f,row){return SPEC.data.files[f].keys.map(k=>row[k]).join('|');}

async function previewMetric(row){
  const out=$('sp_prevout');
  if(!S.applied||!S.product){out.innerHTML='<div class="lintmsg warn">Apply a scope in the bar above first.</div>';return;}
  const scr=rowsOf('screens').filter(s=>s.status!=='retired');
  const pivot=(S.call&&scr.some(s=>s.pivot===S.call.pivot))?S.call.pivot:(scr[0]||{}).pivot;
  const req={client:META.client,env:'qa',engine:'spec',defnId:pivot,aggBy:'level:department',
    scope:{productLevel:'department',productMember:S.product.id,locationLevel:'channel',locationMember:S.location.id},
    filters:S.ps.size&&S.ps.size<META.price_status.length?{merchcat:[...S.ps]}:{},flowStatus:[...S.flow].sort(),metrics:[row.metric_id]};
  if(S.hist){req.scope.historyStart=S.hist.start;req.scope.historyEnd=S.hist.end;}
  if(S.asst){req.scope.start=S.asst.start;req.scope.end=S.asst.end;}
  out.innerHTML='<div class="banner run" style="margin-top:8px">Computing on QA…</div>';
  const r=await api('/api/v2/validate',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(req)}).catch(e=>({status:'ERROR',error:String(e)}));
  if(r.status==='ERROR'){out.innerHTML=`<div class="banner ERROR" style="margin-top:8px">${esc(r.error)}</div>`;return;}
  const rows=r.rows||[];const fs={0:'New',1:'Carryover',2:'Sell Down'};
  out.innerHTML=`<div class="lbl" style="margin-top:8px">${esc(S.product.name)} · ${esc(pivot)} population · by flow status</div>
    <table class="t">${rows.map(x=>`<tr><td>${esc(fs[x.class]??x.class??'all')}</td><td>${fmtN(x[row.metric_id])}</td></tr>`).join('')}</table>
    <details style="margin-top:6px"><summary class="muted" style="cursor:pointer">SQL</summary><pre class="code">${esc((r.sql||{}).rows||'')}</pre></details>`;
}

// ---------- coverage (screen section → spec)
async function drawCoverage(){
  if(!S.call){$('cov_table').innerHTML='<div class="muted">Pick a screen and a section on the Validate tab.</div>';return;}
  $('cov_where').textContent=`${S.top} › ${S.left} › ${S.view} · ${S.call.viewdefns[0]}`;
  const rows=await api(`/api/v2/spec/coverage?pivot=${encodeURIComponent(S.call.pivot)}&viewdefn=${encodeURIComponent(S.call.viewdefns[0])}`);
  if(!SPEC.meta)await loadSpec();
  const n=rows.filter(r=>r.metric_id).length, m=rows.filter(r=>r.status!=='n/a').length;
  $('cov_table').innerHTML=`<div class="muted" style="margin-bottom:6px">${n} of ${m} metric columns have a spec · ${rows.filter(r=>r.drift).length} drift</div>
   <table class="e"><tr><th>Column</th><th>Spec metric</th><th>Spec formula (what it should be)</th><th>Pivot today (as-built)</th><th>Screen rollup</th><th></th></tr>
   ${rows.map((r,i)=>`<tr><td><b>${esc(r.label)}</b><br/><code>${esc(r.data_index)}</code></td>
     <td>${r.metric_id?`<code>${esc(r.metric_id)}</code><br/><span class="st ${esc(r.metric_status)}">${esc(r.metric_status)} v${esc(r.metric_version)}</span>`:r.status==='n/a'?'<span class="st n/a">attribute</span>':'<span class="st unbound">no spec</span>'}</td>
     <td><code>${esc(r.spec_formula)}</code></td><td><code>${esc(r.pivot_formula||r.pivot_expr)}</code></td>
     <td><code>${esc(r.rollup_formula)}</code>${r.drift?`<div class="drift">⚠ ${esc(r.drift)}</div>`:''}</td>
     <td>${r.metric_id?`<button class="btn" data-open="${esc(r.metric_id)}">Open</button>`:r.status==='n/a'?'':`<button class="btn p" data-create="${i}">+ Create metric</button>`}</td></tr>`).join('')}</table>`;
  $('cov_table').querySelectorAll('[data-open]').forEach(b=>b.onclick=()=>{SPEC.file='metrics';SPEC.sel=b.dataset.open;SPEC.isNew=false;showView('spec');});
  $('cov_table').querySelectorAll('[data-create]').forEach(b=>b.onclick=()=>createFromColumn(rows[+b.dataset.create]));
}
window.covChanged=()=>{if($('v_cov').classList.contains('on'))drawCoverage();};
function afterSpecChange(){if(S.call)pickCallRefresh();}
function pickCallRefresh(){api(`/api/v2/spec/coverage?pivot=${encodeURIComponent(S.call.pivot)}&viewdefn=${encodeURIComponent(S.call.viewdefns[0])}`)
  .then(rows=>{S.cov={};rows.forEach(r=>S.cov[r.data_index]=r);drawMetrics();});}

async function createFromColumn(r){
  // the pivot's as-built formula is shown as a HINT only; the spec must come from the requirement
  SPEC.file='metrics';SPEC.sel=null;SPEC.isNew=true;showView('spec');
  await loadSpec(true);drawRail();drawTable();
  drawDrawer({metric_id:r.data_index,label:r.label,type:'derived',expr:'',round:'',
    notes:`Screen: ${r.viewdefn} · ${r.label}\nPivot today (as-built, for reference only — write the formula from the requirement): ${r.pivot_expr||r.pivot_formula}`});
  const msg=$('sp_msgs');if(msg)msg.innerHTML=`<div class="lintmsg warn">• Write the formula from the requirement (ticket / functional owner), not from the pivot. After saving, it is bound to ${esc(r.viewdefn)}.${esc(r.data_index)}.</div>`;
  const save=$('sp_save');const orig=save.onclick;
  save.onclick=async()=>{await orig();
    if(!SPEC.isNew){await api('/api/v2/spec/bindings',{method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({row:{pivot:r.pivot,viewdefn:r.viewdefn,data_index:r.data_index,label:r.label,metric_id:$('sp_form').metric_id.value.trim(),rollup_formula:r.rollup_formula,notes:r.notes},user:me()})}).catch(()=>{});
      afterSpecChange();}};
}

// restore last tab
(async()=>{try{const v=store.get('view');const m=await api('/api/v2/spec/meta');$('me').textContent=m.user;if(v&&v!=='validate')showView(v);}catch(e){}})();
