export class SpeechManager {
  speak(text, lang){
    if(!('speechSynthesis' in window)) return alert('Speech not supported');
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = {zh:'zh-CN',es:'es-ES',fr:'fr-FR',de:'de-DE',it:'it-IT',pt:'pt-BR',ru:'ru-RU',ja:'ja-JP',ko:'ko-KR'}[lang] || 'en-US';
    utter.rate = 0.9;
    speechSynthesis.cancel(); // stop previous
    speechSynthesis.speak(utter);
  }
}