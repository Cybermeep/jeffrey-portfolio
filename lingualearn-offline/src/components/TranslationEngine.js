import { EventEmitter } from '../utils/EventEmitter.js';
export class TranslationEngine extends EventEmitter {
  constructor(){ super(); this.models=new Map(); this.ready=this.init(); }
  async init(){
    // load sample packs synchronously
    ['es','fr','de','zh','ja','ko'].forEach(this.addSamplePack);
    this.emit('ready');
  }
  addSamplePack=(code)=>{
    const packs = {
      es:{hello:'hola',thank:'gracias','good morning':'buenos días'},
      fr:{hello:'bonjour',thank:'merci','good morning':'bonjour'},
      de:{hello:'hallo',thank:'danke','good morning':'guten morgen'},
      zh:{hello:'你好',thank:'谢谢','good morning':'早上好'},
      ja:{hello:'こんにちは',thank:'ありがとう','good morning':'おはよう'},
      ko:{hello:'안녕하세요',thank:'감사합니다','good morning':'좋은아침'}
    };
    this.models.set(code,{language:code,dict:packs[code]||{}});
  }
  getInstalledLanguages(){ return Array.from(this.models.keys()).map(c=>({code:c,name:c.toUpperCase()})) }
  async translate(text,src,tgt){
    if(tgt==='auto'||!tgt) throw new Error('Target language required');
    if(!this.models.has(tgt)) throw new Error('Language pack not installed');
    const model = this.models.get(tgt);
    const lower = text.toLowerCase().trim();
    const trans = model.dict[lower] || this.wordByWord(lower,model);
    const pron = {zh:'nǐ hǎo',ja:'konnichiwa',ko:'annyeonghaseyo'}[tgt]||trans;
    return {text:trans,pronunciation:pron,confidence:.95};
  }
  wordByWord(txt,model){
    return txt.split(' ').map(w=>model.dict[w]||w).join(' ');
  }
}