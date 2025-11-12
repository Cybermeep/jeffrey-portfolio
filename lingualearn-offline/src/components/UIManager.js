import { EventEmitter } from '../utils/EventEmitter.js';
export class UIManager extends EventEmitter {
  constructor(xlat, ocr, speech){ super(); this.x=xlat; this.o=ocr; this.s=speech; }
  render(){
    const root = document.getElementById('root');
    root.innerHTML = `
      <header><h1>LinguaLearn Pro</h1></header>
      <section class="section">
        <div class="card">
          <div class="lang-row">
            <select id="srcLang"><option value="auto">Auto-detect</option></select>
            <button class="btn btn-secondary" id="swap">⇄</button>
            <select id="tgtLang"></select>
          </div>
          <textarea id="inputTxt" placeholder="Enter text…"></textarea>
          <div class="actions">
            <button class="btn btn-secondary" id="clear">Clear</button>
            <button class="btn btn-primary" id="transBtn">Translate</button>
          </div>
          <div id="out" class="card" style="margin-top:1rem;display:none"></div>
        </div>
        <div class="card">
          <h3>Camera / OCR</h3>
          <input type="file" accept="image/*" id="imgIn">
          <div id="ocrOut" style="margin-top:.5rem;font-size:.9rem"></div>
        </div>
      </section>`;
    this.populateLangs();
    this.attachHandlers();
  }
  populateLangs(){
    const langs = this.x.getInstalledLanguages();
    const tgt = document.getElementById('tgtLang');
    langs.forEach(l=> tgt.innerHTML += `<option value="${l.code}">${l.name}</option>`);
  }
  attachHandlers(){
    document.getElementById('transBtn').onclick = ()=>this.translate();
    document.getElementById('clear').onclick  = ()=>{ document.getElementById('inputTxt').value=''; document.getElementById('out').style.display='none'; };
    document.getElementById('swap').onclick  = ()=>{ const s=document.getElementById('srcLang'), t=document.getElementById('tgtLang'); const tmp=s.value; s.value=t.value; t.value=tmp; };
    document.getElementById('imgIn').onchange = (e)=>this.ocrImage(e.target.files[0]);
  }
  async translate(){
    const txt = document.getElementById('inputTxt').value.trim();
    if(!txt) return;
    const src = document.getElementById('srcLang').value;
    const tgt = document.getElementById('tgtLang').value;
    if(!tgt) return alert('Pick target language');
    try{
      const res = await this.x.translate(txt, src, tgt);
      const out = document.getElementById('out');
      out.innerHTML = `<div><strong>Translation</strong><br>${res.text}</div>
                       ${res.pronunciation?`<div class="status">Pronunciation: ${res.pronunciation}</div>`:''}
                       <button class="btn btn-secondary" onclick="app.speech.speak('${res.text.replace(/'/g,"\\'")}', '${tgt}')">🔊 Speak</button>`;
      out.style.display='block';
    }catch(e){ alert('Translation failed: '+e.message); }
  }
  async ocrImage(file){
    if(!file) return;
    const tgt = document.getElementById('tgtLang').value;
    if(!tgt) return alert('Pick target language first');
    document.getElementById('ocrOut').textContent = 'Reading image…';
    try{
      const data = await this.o.recognize(URL.createObjectURL(file));
      document.getElementById('ocrOut').textContent = data.text || 'No text found';
      if(data.text) {
        document.getElementById('inputTxt').value = data.text;
        await this.translate();
      }
    }catch(e){ alert('OCR failed: '+e.message); }
  }
}