let htmlTemplate = #"""
<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
  :root{
    --bg:#ececec; --panel:#ffffff; --ink:#1d1d1f; --muted:#86868b; --line:#dcdcdc;
    --accent:#0a72ff; --code-bg:#f2f2f4; --hover:#f0f0f2; --hair:rgba(0,0,0,.08); --danger:#e0384e;
  }
  @media (prefers-color-scheme: dark){
    :root{ --bg:#232326; --panel:#2b2b2f; --ink:#f2f2f5; --muted:#98989f; --line:#3a3a40;
           --accent:#4c93ff; --code-bg:#1c1c20; --hover:#34343a; --hair:rgba(255,255,255,.08); --danger:#ff5f6d; }
  }
  *{box-sizing:border-box}
  html,body{margin:0;height:100%;
    font:13px/1.5 -apple-system,BlinkMacSystemFont,'SF Pro Text',system-ui,sans-serif;
    background:var(--bg);color:var(--ink);-webkit-font-smoothing:antialiased}
  .wrap{display:flex;flex-direction:column;height:100vh}

  /* nav bar */
  header{display:flex;align-items:center;gap:8px;height:44px;padding:0 10px;-webkit-app-region:drag}
  header .mid{flex:1;text-align:center;font-size:13px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
  header .nav{-webkit-app-region:no-drag;appearance:none;border:0;background:transparent;color:var(--accent);
    font-size:13px;font-weight:500;cursor:pointer;padding:6px 8px;border-radius:7px;min-width:58px;white-space:nowrap}
  header .nav:hover{background:var(--hover)}
  header .nav.r{text-align:right} header .nav.l{text-align:left}
  header .nav.mut{color:var(--muted)} header .nav.strong{font-weight:600}
  header .plus{-webkit-app-region:no-drag;appearance:none;border:0;background:transparent;color:var(--accent);
    font-size:20px;font-weight:300;cursor:pointer;line-height:1;padding:2px 8px;border-radius:7px}
  header .plus:hover{background:var(--hover)}
  .spring{flex:1}

  main{flex:1;overflow:auto;background:var(--panel);margin:0 12px;border:.5px solid var(--line);border-radius:12px}
  main.pad{padding:16px 18px 20px}
  main::-webkit-scrollbar{width:9px}
  main::-webkit-scrollbar-thumb{background:rgba(140,140,150,.4);border-radius:9px;border:2px solid transparent;background-clip:content-box}

  /* home list */
  .list{padding:4px 0}
  .row{display:flex;align-items:center;gap:10px;padding:11px 16px;cursor:pointer;border-bottom:.5px solid var(--line)}
  .row:last-child{border-bottom:0}
  .row:hover{background:var(--hover)}
  .row .ic{width:30px;height:30px;border-radius:7px;background:var(--code-bg);display:flex;align-items:center;justify-content:center;font-size:15px;flex:0 0 auto}
  .row .tx{flex:1;min-width:0}
  .row .tt{font-weight:600;font-size:13.5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .row .pv{color:var(--muted);font-size:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:1px}
  .row .chev{color:var(--muted);font-size:16px;flex:0 0 auto}
  .empty{color:var(--muted);text-align:center;padding:40px 20px;font-size:13px}

  /* rendered markdown */
  h1.md{font-size:17px;font-weight:600;margin:0 0 10px}
  h2.md{font-size:13.5px;font-weight:600;margin:18px 0 6px}
  h2.md::before{content:"";display:block;height:.5px;background:var(--line);margin-bottom:9px}
  h3.md{font-size:12.5px;font-weight:600;margin:13px 0 4px;color:var(--muted)}
  p{margin:6px 0} ul{margin:6px 0;padding-left:18px} li{margin:3px 0}
  hr{border:0;border-top:.5px solid var(--line);margin:14px 0}
  code{background:var(--code-bg);padding:1px 5px;border-radius:5px;font:11.5px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace}
  pre{background:var(--code-bg);border:.5px solid var(--line);border-radius:8px;padding:10px 12px;overflow-x:auto;margin:8px 0}
  pre code{background:none;padding:0;font-size:11.5px;color:var(--ink)}
  blockquote{margin:9px 0;padding:2px 0 2px 12px;border-left:2px solid var(--line);color:var(--muted)}
  a{color:var(--accent);text-decoration:none} strong{font-weight:600}

  /* editor */
  .edit{display:flex;flex-direction:column;height:100%}
  .edit textarea{flex:1;width:100%;resize:none;border:0;outline:0;background:transparent;color:var(--ink);
    padding:16px 18px;font:12.5px/1.6 ui-monospace,SFMono-Regular,Menlo,monospace;-webkit-app-region:no-drag}
  .hint{color:var(--muted);font-size:11px;padding:6px 18px;border-top:.5px solid var(--line);display:flex;align-items:center}
  .hint .del{margin-left:auto;color:var(--danger);cursor:pointer;font-weight:500}

  footer{display:flex;align-items:center;gap:2px;padding:7px 10px 9px}
  .btn{appearance:none;border:0;background:transparent;color:var(--accent);
    padding:6px 9px;border-radius:7px;font-size:12.5px;font-weight:500;cursor:pointer}
  .btn:hover{background:var(--hover)} .btn.mut{color:var(--muted)}
</style></head>
<body><div class="wrap">
  <header id="bar"></header>
  <main id="app"></main>
  <footer id="foot"></footer>
</div>
<script>
  const NOTES = /*__NOTES__*/;
  let view = "/*__VIEW__*/";           // home | note | edit
  let active = /*__ACTIVE__*/;
  let draft = null;

  function cur(){ return NOTES[active] || {name:'',title:'',body:''}; }
  function send(action, extra){ try{ window.webkit.messageHandlers.bridge.postMessage(Object.assign({action:action}, extra||{})); }catch(e){} }
  function escHtml(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function titleOf(body){ const m=(body||'').split('\n').find(l=>/^#\s/.test(l.trim())); return m?m.trim().replace(/^#\s+/,''):'Untitled'; }
  function firstText(body){
    const lines=(body||'').split('\n');
    for(let i=0;i<lines.length;i++){ let l=lines[i].trim();
      if(!l||/^#/.test(l)||l.indexOf('---')===0||l.indexOf('```')===0) continue;
      return l.replace(/[*`>#_\[\]]/g,'').replace(/\(([^)]+)\)/g,'').slice(0,90);
    } return 'No additional text';
  }
  function slugify(t){ return (t||'').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-+|-+$/g,'') || 'note'; }
  function uniqueSlug(t){ let b=slugify(t), s=b, i=2; const names=NOTES.map(n=>n.name.toLowerCase());
    while(names.indexOf(s)>=0){ s=b+'-'+i; i++; } return s; }

  function inl(s){ return s
    .replace(/`([^`]+)`/g,function(m,c){return '<code>'+c+'</code>';})
    .replace(/\*\*([^*]+)\*\*/g,'<strong>$1</strong>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g,'<a href="$2">$1</a>'); }
  function md(src){
    const L=(src||'').split('\n'); let out=''; let i=0; let inList=false;
    const closeL=()=>{ if(inList){out+='</ul>';inList=false;} };
    while(i<L.length){ let line=L[i];
      if(line.trim().indexOf('```')===0){ closeL(); i++; let code='';
        while(i<L.length && L[i].trim().indexOf('```')!==0){ code+=L[i]+'\n'; i++; } i++;
        out+='<pre><code>'+escHtml(code.replace(/\n$/,''))+'</code></pre>'; continue; }
      if(/^#{1,6}\s/.test(line)){ closeL(); const m=line.match(/^(#{1,6})\s+(.*)$/); let lvl=m[1].length; if(lvl>3)lvl=3;
        out+='<h'+lvl+' class="md">'+inl(escHtml(m[2]))+'</h'+lvl+'>'; }
      else if(/^\s*---\s*$/.test(line)){ closeL(); out+='<hr>'; }
      else if(/^>\s?/.test(line)){ closeL(); let bq='';
        while(i<L.length && /^>\s?/.test(L[i])){ bq+=inl(escHtml(L[i].replace(/^>\s?/,'')))+'<br>'; i++; }
        out+='<blockquote>'+bq.replace(/<br>$/,'')+'</blockquote>'; continue; }
      else if(/^\s*[-*]\s+/.test(line)){ if(!inList){out+='<ul>';inList=true;} out+='<li>'+inl(escHtml(line.replace(/^\s*[-*]\s+/,'')))+'</li>'; }
      else if(line.trim()===''){ closeL(); }
      else { closeL(); out+='<p>'+inl(escHtml(line))+'</p>'; }
      i++;
    } closeL(); return out;
  }

  const bar=()=>document.getElementById('bar');
  const appEl=()=>document.getElementById('app');
  const foot=()=>document.getElementById('foot');

  function goHome(){ view='home'; draft=null; route(); }
  function openNote(i){ active=i; view='note'; route(); }
  function openEdit(){ const n=cur(); draft={name:n.name, body:n.body, isNew:false}; view='edit'; route(); }
  function addNote(){ draft={name:'', body:'# New note\n\n', isNew:true}; view='edit'; route(); }
  function cancelEdit(){ draft=null; view = (NOTES.length? (cur().name?'note':'home'):'home'); route(); }
  function saveEdit(){
    const body=document.getElementById('ta').value; const title=titleOf(body);
    let name=draft.name;
    if(draft.isNew){ name=uniqueSlug(title); NOTES.push({name:name,title:title,body:body}); active=NOTES.length-1; }
    else { const i=NOTES.findIndex(x=>x.name===name); if(i>=0){ NOTES[i].body=body; NOTES[i].title=title; active=i; } }
    send('save',{name:name, body:body});
    draft=null; view='note'; route();
  }
  function delNote(){ const n=cur(); if(!confirm('Delete “'+n.title+'”? This removes the note and its Spotlight app.')) return;
    send('delete',{name:n.name}); NOTES.splice(active,1); active=0; draft=null; view='home'; route(); }

  function route(){
    if(view==='home'){
      bar().innerHTML='<span class="spring"></span><div class="mid">NAS · Notes</div><span class="spring"></span>'
        +'<button class="plus" title="New note" onclick="addNote()">+</button>';
      appEl().className='';
      appEl().innerHTML = NOTES.length ? '<div class="list">'+NOTES.map(function(n,idx){
          return '<div class="row" onclick="openNote('+idx+')"><div class="ic">'+(n.name==='email'?'✉️':'🗄️')+'</div>'
            +'<div class="tx"><div class="tt">'+escHtml(n.title)+'</div><div class="pv">'+escHtml(firstText(n.body))+'</div></div>'
            +'<div class="chev">›</div></div>';
        }).join('')+'</div>'
        : '<div class="empty">No notes yet.<br>Tap + to add one.</div>';
      foot().innerHTML='<button class="btn mut" onclick="send(\'reveal\')">Folder</button>'
        +'<span class="spring"></span><button class="btn mut" onclick="send(\'quit\')">Quit</button>';
    }
    else if(view==='note'){
      const n=cur();
      bar().innerHTML='<button class="nav l" onclick="goHome()">‹ Notes</button>'
        +'<div class="mid">'+escHtml(n.title)+'</div>'
        +'<button class="nav r strong" onclick="openEdit()">Edit</button>';
      appEl().className='pad'; appEl().innerHTML=md(n.body); appEl().scrollTop=0;
      foot().innerHTML='<button class="btn" onclick="send(\'copy\',{text:cur().body})">Copy</button>'
        +'<button class="btn" onclick="send(\'cherrytree\')">CherryTree</button>'
        +'<button class="btn mut" onclick="send(\'reveal\')">Folder</button>'
        +'<span class="spring"></span><button class="btn mut" onclick="send(\'quit\')">Quit</button>';
    }
    else if(view==='edit'){
      bar().innerHTML='<button class="nav l mut" onclick="cancelEdit()">Cancel</button>'
        +'<div class="mid">'+(draft.isNew?'New Note':'Editing')+'</div>'
        +'<button class="nav r strong" onclick="saveEdit()">Save</button>';
      appEl().className='';
      appEl().innerHTML='<div class="edit"><textarea id="ta" spellcheck="false"></textarea>'
        +'<div class="hint">Markdown · first “# ” line becomes the title'
        +(draft.isNew?'':'<span class="del" onclick="delNote()">Delete note</span>')+'</div></div>';
      const ta=document.getElementById('ta'); ta.value=draft.body; ta.focus();
      foot().innerHTML='';
    }
  }
  route();
</script></body></html>
"""#
