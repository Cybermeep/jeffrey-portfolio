import { TranslationEngine } from './components/TranslationEngine.js';
import { OCRManager } from './components/OCRManager.js';
import { SpeechManager } from './components/SpeechManager.js';
import { UIManager } from './components/UIManager.js';

class App {
  constructor() {
    this.xlat = null; this.ocr = null; this.speech = null; this.ui = null;
    this.init();
  }
  async init() {
    // hide skeleton
    document.getElementById('appLoader').style.display = 'none';
    document.getElementById('root').style.display = 'block';

    this.xlat = new TranslationEngine();
    this.ocr = new OCRManager();
    this.speech = new SpeechManager();
    this.ui = new UIManager(this.xlat, this.ocr, this.speech);

    await this.xlat.ready;
    this.ui.render();
  }
}
new App();