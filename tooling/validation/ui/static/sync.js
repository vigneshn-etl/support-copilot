// Sync with QA: Sync with QA DB (ClickHouse schema + freshness) and Pull metrics from QA (live config vs catalog)
const SY={met:null};
const ago=t=>{if(!t)return 'never';const s=Date.now()/1000-t;return s<3600?`${Math.round(s/60)} min ago`:s<86400?`${Math.round(s/3600)} h ago`:`${Math.round(s/86400)} days ago`;};
async function syncStatus(){
  const st=await api('/api/v2/sync/status');
  const c=st.config||{};
  $('sy_cfg').textContent=`QA config pulled ${ago(c.last_synced)} · ${c.files||0} files · scope: ${st.scope.join(', ')}`;
  $('sy_runs').innerHTML=st.runs.length?`<table class="e"><tr><th>When</th><th>What</th><th>Result</th><th></th></tr>${st.runs.map(r=>`<tr><td>${esc((r.ran_at||'').replace('T',' '))}</td><td>${r.kind==='qa_db'?'Sync with QA DB':'Pull metrics from QA'}</td><td>${esc(Object.entries(r.counts||{}).map(([k,v])=>k.replace(/_/g,' ')+' '+v).join(' · '))}</td><td><a href="#" data-f="${esc(r.file)}">open</a></td></tr>`).join('')}</table>`:'No runs yet.';
  $('sy_runs').querySelectorAll('a[data-f]').forEach(a=>a.onclick=async e=>{e.preventDefault();const r=await api('/api/v2/sync/run/'+a.dataset.f);r.kind==='qa_db'?drawDb(r):drawMet(r);});
  for(const [k,j] of Object.entries(st.jobs||{})) if(j.state==='running') poll(k);
}
async function start(kind,body){
  try{await api('/api/v2/sync/'+(kind==='qa_db'?'qa-db':'qa-metrics'),{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body||{})});}
  catch(e){$('sy_job').textContent=String(e);return;}
  poll(kind);
}
async function poll(kind){
  const j=await api('/api/v2/sync/job/'+kind);
  const t0=j.started?Math.round(Date.now()/1000-j.started):0;
  if(j.state==='running'){$('sy_job').innerHTML=`<span class="spin"></span> ${esc(j.step)} … ${t0}s`;setTimeout(()=>poll(kind),2000);return;}
  if(j.state==='failed'){$('sy_job').innerHTML=`<span style="color:var(--bad)">Failed: ${esc(j.error)}</span>`;return;}
  $('sy_job').textContent=`Done in ${t0}s.`;
  kind==='qa_db'?drawDb(j.result):drawMet(j.result);
  syncStatus();
}
function drawDb(r){
  const el=$('sy_dbout');el.style.display='';
  const fr=Object.entries(r.freshness||{}).map(([s,f])=>`<b>${esc(s)}</b> latest ${esc(f.latest_week)}${f.rows?` (${Number(f.rows).toLocaleString()} rows)`:''}`).join(' · ');
  el.innerHTML=`<h3>QA ClickHouse vs catalog <span class="r muted">${esc((r.ran_at||'').replace('T',' '))}</span></h3>
   <div style="margin-bottom:8px">${r.counts.errors?`<b style="color:var(--bad)">${r.counts.errors} problem(s)</b>`:'<b style="color:var(--ok)">Aligned</b>'}: ${r.counts.tables_ok}/${r.counts.tables} tables have every column the catalog reads.</div>
   <div class="muted" style="margin-bottom:8px">Data freshness: ${fr}</div>
   ${r.issues.length?`<table class="e"><tr><th>Table</th><th>Column</th><th>Problem</th><th>Used by</th></tr>${r.issues.map(i=>`<tr><td>${esc(i.table)}</td><td><code>${esc(i.column)}</code></td><td>${esc(i.msg)}</td><td>${esc(i.used_by.join(', '))}</td></tr>`).join('')}</table>`:''}
   <table class="e"><tr><th>Table</th><th>Status</th><th>Columns on QA</th><th>Used by catalog</th></tr>${r.tables.map(t=>`<tr><td>${esc(t.table)}</td><td>${esc(t.status)}</td><td>${t.columns}</td><td>${t.used}</td></tr>`).join('')}</table>`;
}
function drawMet(r){
  SY.met=r;const el=$('sy_metout');el.style.display='';
  const c=r.counts;
  const sec=(title,rows,cols,check)=>rows.length?`<h4 style="margin:14px 0 6px">${title} (${rows.length})</h4><div class="scroll" style="max-height:320px"><table class="e"><tr>${check?'<th></th>':''}${cols.map(x=>`<th>${x[0]}</th>`).join('')}</tr>${rows.map((x,i)=>`<tr>${check?`<td><input type="checkbox" data-i="${i}" ${x.screen_in_catalog?'':'disabled title="add the screen first"'}></td>`:''}${cols.map(k=>`<td>${k[1](x)}</td>`).join('')}</tr>`).join('')}</table></div>`:'';
  const col=x=>`${esc(x.viewdefn)}.<code>${esc(x.data_index)}</code>`;
  const missingScreens=r.screens.filter(s=>!s.in_catalog);
  el.innerHTML=`<h3>QA screens vs catalog <span class="r muted">${esc((r.ran_at||'').replace('T',' '))}</span></h3>
   <table class="e"><tr><th>Data call</th><th>In catalog</th><th>Columns on QA</th><th>Bound to a metric</th><th>New on QA</th></tr>${r.screens.map(s=>`<tr><td>${esc(s.pivot)}</td><td>${s.in_catalog?'yes':'<b>no</b>'}</td><td>${s.qa_columns}</td><td>${s.bound}</td><td>${s.new}</td></tr>`).join('')}</table>
   <div class="muted" style="margin:6px 0">${c.rollup_changed} screen rollup(s) changed on QA · ${c.removed} column(s) gone from QA · ${c.pivot_changed_vs_git} column(s) where QA's pivot differs from git · ${c.unbound} catalog column(s) still unbound</div>
   ${missingScreens.length?`<div style="margin:8px 0">Not in the catalog yet: ${missingScreens.map(s=>`<button class="btn sm" data-addscr="${esc(s.pivot)}">+ Add ${esc(s.pivot)} (population HIST_STD, history weeks)</button>`).join(' ')}</div>`:''}
   ${sec('Screen rollup changed on QA',r.rollup_changed,[['Column',col],['Catalog rollup',x=>`<code>${esc(x.catalog_rollup)}</code>`],['QA rollup',x=>`<code>${esc(x.view_formula)}</code>`]])}
   ${sec('New on QA (not in the catalog)',r.new,[['Column',col],['Label',x=>esc(x.label)],['Views',x=>esc(x.screens.join(', '))],['Screen rollup',x=>`<code>${esc(x.view_formula)}</code>`],['Metric',x=>x.metric_guess?`<code>${esc(x.metric_guess)}</code>`:'<span class="muted">none yet</span>']],true)}
   ${r.new.length?`<button class="btn" id="sy_apply">Add selected as draft columns</button> <span class="muted">You then bind or create each metric in Spec.</span>`:''}
   ${sec('Gone from QA (in the catalog)',r.removed,[['Column',col],['Metric',x=>esc(x.metric_id)]])}
   ${sec("QA's pivot differs from git",r.pivot_changed_vs_git,[['Column',col],['git',x=>`<code>${esc(x.git_formula.slice(0,120))}</code>`],['QA',x=>`<code>${esc(x.base_formula.slice(0,120))}</code>`]])}`;
  el.querySelectorAll('[data-addscr]').forEach(b=>b.onclick=()=>applySel([], [{pivot:b.dataset.addscr,population_id:'HIST_STD',time_mode:'history',split_by_class:'yes'}]));
  const ap=$('sy_apply'); if(ap) ap.onclick=()=>{const sel=[...el.querySelectorAll('input[data-i]:checked')].map(x=>r.new[+x.dataset.i]);applySel(sel,[]);};
}
async function applySel(items,screens){
  if(!items.length&&!screens.length){$('sy_job').textContent='Select at least one column.';return;}
  try{const r=await api('/api/v2/sync/qa-metrics/apply',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({items,screens,user:me()})});
    $('sy_job').textContent=`Added as drafts: ${[...r.screens,...r.bindings].join(', ')}. Re-run "Pull metrics from QA" to refresh.`;}
  catch(e){$('sy_job').textContent='Not added: '+JSON.stringify(e);}
}
$('sy_db').onclick=()=>start('qa_db');
$('sy_met').onclick=()=>start('qa_metrics',{refresh:$('sy_refresh').checked});
