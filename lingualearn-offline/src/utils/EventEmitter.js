export class EventEmitter {
  constructor(){ this.e = {} }
  on(n, fn){ (this.e[n]||(this.e[n]=[])).push(fn) }
  off(n, fn){ if(this.e[n]) this.e[n]=this.e[n].filter(f=>f!==fn) }
  emit(n, ...a){ if(this.e[n]) this.e[n].forEach(fn=>fn(...a)) }
}