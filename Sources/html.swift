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

  /* clipboard */
  .chips{display:flex;gap:6px;padding:8px 12px 6px;overflow-x:auto}
  .chips::-webkit-scrollbar{display:none}
  .chip{flex:0 0 auto;border:.5px solid var(--line);background:var(--code-bg);color:var(--muted);
    padding:4px 11px;border-radius:999px;font-size:11.5px;font-weight:600;cursor:pointer;white-space:nowrap}
  .chip.active{background:var(--accent);border-color:var(--accent);color:#fff}
  .daterow{font-size:10.5px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;padding:13px 16px 5px}
  .clip{display:flex;gap:10px;align-items:flex-start;padding:10px 14px;border-bottom:.5px solid var(--line);cursor:pointer}
  .clip:last-child{border-bottom:0}
  .clip:hover{background:var(--hover)}
  .clip .cbody{flex:1;min-width:0}
  .badge{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.4px;padding:2px 6px;border-radius:5px;
    background:var(--code-bg);color:var(--muted);text-transform:uppercase;margin-bottom:5px}
  .badge.link{color:#0a72ff} .badge.code{color:#a855f7} .badge.path{color:#0ea5a5}
  .badge.image{color:#e0873a} .badge.video{color:#e0384e} .badge.file{color:#7d8797} .badge.text{color:#7d8797}
  .badge.email{color:#0a72ff} .badge.phone{color:#22a06b} .badge.color{color:#e0873a} .badge.ip{color:#7c7cff} .badge.error{color:#e0384e}
  .cnt{display:inline-block;margin-left:6px;font-size:9.5px;font-weight:700;padding:2px 6px;border-radius:999px;
    background:var(--accent);color:#fff;vertical-align:top}
  .swatch{width:42px;height:42px;border-radius:9px;border:.5px solid var(--line);flex:0 0 auto}
  .search{margin:2px 12px 4px;padding:7px 11px;border:.5px solid var(--line);border-radius:9px;
    background:var(--code-bg);color:var(--ink);font-size:12.5px;outline:none}
  .search:focus{border-color:var(--accent)}
  .clip .star{color:var(--muted);font-size:14px;padding:0 3px;line-height:1.3;align-self:flex-start;cursor:pointer}
  .clip .star.on{color:#f0a500}
  .prev{font-size:12.5px;color:var(--ink);white-space:pre-wrap;word-break:break-word;
    display:-webkit-box;-webkit-line-clamp:4;-webkit-box-orient:vertical;overflow:hidden}
  .prev.mono{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:11px;background:var(--code-bg);
    padding:8px 10px;border-radius:7px;-webkit-line-clamp:6;line-height:1.45}
  .prev.linkish{color:var(--accent)}
  .clip img.thumb{max-width:130px;max-height:84px;border-radius:7px;border:.5px solid var(--line);display:block}
  .cmeta{font-size:10.5px;color:var(--muted);margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .clip .x{color:var(--muted);font-size:15px;align-self:flex-start;padding:0 4px;line-height:1.2}
  .clip .x:hover{color:var(--danger)}
  .ficon{width:42px;height:42px;border-radius:9px;background:var(--code-bg);display:flex;align-items:center;justify-content:center;font-size:20px;flex:0 0 auto}

  /* copy toast */
  #toast{position:fixed;left:50%;bottom:16px;transform:translate(-50%,20px);opacity:0;pointer-events:none;
    display:flex;align-items:center;gap:10px;max-width:82%;padding:9px 13px;border-radius:12px;
    background:var(--panel);border:.5px solid var(--line);box-shadow:0 8px 26px rgba(0,0,0,.28);
    transition:opacity .18s ease,transform .18s ease;z-index:50}
  #toast.show{opacity:1;transform:translate(-50%,0)}
  #toast .ticon{width:26px;height:26px;border-radius:6px;background:var(--code-bg);display:flex;align-items:center;
    justify-content:center;font-size:14px;flex:0 0 auto;overflow:hidden}
  #toast .ticon img.thumb{max-width:26px;max-height:26px;border:0;border-radius:5px}
  #toast .ticon .swatch,#toast .ticon .ficon{width:26px;height:26px;border-radius:6px;font-size:14px}
  #toast .tt{font-size:11px;font-weight:700;color:var(--accent);text-transform:uppercase;letter-spacing:.3px}
  #toast .ts{font-size:12px;color:var(--ink);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:340px}

  footer{display:flex;align-items:center;gap:2px;padding:7px 10px 9px}
  .btn{appearance:none;border:0;background:transparent;color:var(--accent);
    padding:6px 9px;border-radius:7px;font-size:12.5px;font-weight:500;cursor:pointer}
  .btn:hover{background:var(--hover)} .btn.mut{color:var(--muted)}
</style></head>
<body><div class="wrap">
  <header id="bar"></header>
  <main id="app"></main>
  <footer id="foot"></footer>
  <div id="toast"></div>
</div>
<script>
  const NOTES = /*__NOTES__*/;
  let CLIPS = /*__CLIPS__*/;
  let view = "/*__VIEW__*/";           // home | note | edit | clips
  let active = /*__ACTIVE__*/;
  let draft = null;
  let clipFilter = 'all';
  let clipSearch = '';

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

  // ---------- clipboard ----------
  function showClips(){ view='clips'; route(); }
  const KINDS=[['fav','★'],['all','All'],['link','Links'],['email','Emails'],['code','Code'],['error','Errors'],
    ['path','Paths'],['color','Colors'],['ip','IPs'],['phone','Phones'],['image','Images'],['video','Videos'],['file','Files'],['text','Text']];
  function twoDigit(n){ return (n<10?'0':'')+n; }
  function timeStr(ts){ const d=new Date(ts*1000); return twoDigit(d.getHours())+':'+twoDigit(d.getMinutes()); }
  function dayKey(ts){ const d=new Date(ts*1000); const n=new Date();
    const dd=new Date(d.getFullYear(),d.getMonth(),d.getDate()); const t0=new Date(n.getFullYear(),n.getMonth(),n.getDate());
    const diff=Math.round((t0-dd)/86400000);
    if(diff===0) return 'Today'; if(diff===1) return 'Yesterday'; if(diff>1&&diff<7) return d.toLocaleDateString(undefined,{weekday:'long'});
    return d.toLocaleDateString(undefined,{year:'numeric',month:'short',day:'numeric'}); }
  function icon(kind){ return kind==='video'?'🎞':kind==='file'?'📄':kind==='image'?'🖼':'📋'; }
  function badgeText(c){ return c.kind==='code' ? ('Code'+(c.lang?' · '+c.lang:'')) : c.kind; }
  function clipInner(c){
    if(c.kind==='image'){ return (c.thumb?'<img class="thumb" src="'+c.thumb+'">':'<div class="ficon">🖼</div>'); }
    if(c.kind==='video'||c.kind==='file'){ return '<div class="ficon">'+icon(c.kind)+'</div>'; }
    if(c.kind==='color'){ return '<div class="swatch" style="background:'+escHtml(c.preview||'#000')+'"></div>'; }
    return '';
  }
  function clipMain(c){
    let cls='prev', txt=escHtml(c.preview||'');
    if(c.kind==='code'||c.kind==='path'||c.kind==='error') cls='prev mono';
    else if(c.kind==='link'||c.kind==='email') cls='prev linkish';
    let meta='';
    if(c.kind==='image'||c.kind==='video'||c.kind==='file'){ txt=escHtml(c.name||'file'); meta=escHtml(c.path||''); }
    else if(c.len&&c.len>1400){ meta=(c.len)+' chars'; }
    const cnt=(c.count&&c.count>1)?'<span class="cnt">×'+c.count+'</span>':'';
    return '<span class="badge '+c.kind+'">'+escHtml(badgeText(c))+'</span>'+cnt
      +'<div class="'+cls+'">'+txt+'</div>'+(meta?'<div class="cmeta">'+meta+'</div>':'');
  }
  function shortLabel(c){
    if(c.kind==='image'||c.kind==='video'||c.kind==='file') return c.name||'file';
    let s=(c.preview||'').replace(/\s+/g,' ').trim();
    return s.length>60 ? s.slice(0,60)+'…' : s;
  }
  function copyClip(id){
    const c=CLIPS.find(x=>x.id===id); if(!c) return;
    send('clip-copy',{id:id});
    showToast(clipInner(c), 'Now copied · '+badgeText(c), shortLabel(c));
  }
  let toastT=null;
  function showToast(iconHtml, title, sub){
    let t=document.getElementById('toast');
    t.innerHTML='<div class="ticon">'+(iconHtml||'📋')+'</div><div class="tbody"><div class="tt">'
      +escHtml(title)+'</div><div class="ts">'+escHtml(sub||'')+'</div></div>';
    t.classList.add('show');
    if(toastT) clearTimeout(toastT);
    toastT=setTimeout(function(){ t.classList.remove('show'); }, 1900);
  }
  function toggleFav(id,ev){ ev.stopPropagation(); const c=CLIPS.find(x=>x.id===id); if(!c) return;
    c.fav=!c.fav; send('clip-fav',{id:id,fav:!!c.fav}); renderClipList(); }
  function delClip(id,ev){ ev.stopPropagation(); send('clip-delete',{id:id}); CLIPS=CLIPS.filter(c=>c.id!==id); renderClipList(); }
  function clearClips(){ if(!confirm('Clear all clipboard history?')) return; send('clip-clear'); CLIPS=[]; route(); }
  function clipMatches(c){
    const q=clipSearch.trim().toLowerCase(); if(!q) return true;
    return ((c.preview||'')+' '+(c.name||'')+' '+(c.path||'')+' '+(c.lang||'')+' '+c.kind).toLowerCase().indexOf(q)>=0;
  }
  function renderClipList(){
    const cont=document.getElementById('cliplist'); if(!cont) return;
    const list=CLIPS.filter(c=>(clipFilter==='all'||(clipFilter==='fav'?c.fav:c.kind===clipFilter))&&clipMatches(c));
    if(!list.length){ cont.innerHTML='<div class="empty">'+(clipSearch?'No matches.':'Nothing here yet.<br>Copy something and it shows up.')+'</div>'; return; }
    let html='', lastDay='';
    list.forEach(function(c){
      const dk=dayKey(c.ts);
      if(dk!==lastDay){ html+='<div class="daterow">'+escHtml(dk)+'</div>'; lastDay=dk; }
      html+='<div class="clip" onclick="copyClip(\''+c.id+'\')">'
        +clipInner(c)+'<div class="cbody">'+clipMain(c)+'<div class="cmeta">'+timeStr(c.ts)+'</div></div>'
        +'<span class="star'+(c.fav?' on':'')+'" onclick="toggleFav(\''+c.id+'\',event)">'+(c.fav?'★':'☆')+'</span>'
        +'<span class="x" onclick="delClip(\''+c.id+'\',event)">×</span></div>';
    });
    cont.innerHTML=html;
  }

  function route(){
    if(view==='home'){
      bar().innerHTML='<button class="nav l" title="Clipboard" onclick="showClips()">📋 Clipboard</button>'
        +'<div class="mid">NAS · Notes</div><span class="spring"></span>'
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
    else if(view==='clips'){
      bar().innerHTML='<button class="nav l" onclick="goHome()">‹ Notes</button>'
        +'<div class="mid">Clipboard</div>'
        +'<button class="nav r mut" onclick="clearClips()">Clear</button>';
      appEl().className='';
      const present={}; CLIPS.forEach(c=>present[c.kind]=1);
      const chips=KINDS.filter(k=>k[0]==='all'||k[0]==='fav'||present[k[0]]).map(function(k){
        return '<div class="chip'+(clipFilter===k[0]?' active':'')+'" onclick="clipFilter=\''+k[0]+'\';route()">'+escHtml(k[1])+'</div>'; }).join('');
      appEl().innerHTML='<div class="chips">'+chips+'</div>'
        +'<input class="search" id="clipq" type="search" placeholder="Search clipboard…" '
        +'oninput="clipSearch=this.value;renderClipList()" value="'+escHtml(clipSearch)+'">'
        +'<div id="cliplist"></div>';
      renderClipList();
      const q=document.getElementById('clipq'); if(clipSearch){ q.focus(); q.setSelectionRange(q.value.length,q.value.length); }
      appEl().scrollTop=0;
      foot().innerHTML='<button class="btn mut" onclick="goHome()">‹ Notes</button>'
        +'<span class="spring"></span><span class="btn mut" style="cursor:default">'+CLIPS.length+' items</span>'
        +'<button class="btn mut" onclick="send(\'quit\')">Quit</button>';
    }
  }
  route();
</script></body></html>
"""#
