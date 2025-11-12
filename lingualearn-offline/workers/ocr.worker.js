// placeholder for heavy OCR maths
self.addEventListener('message', async e => {
  const {id, imageUrl} = e.data;
  // future: import Tesseract here
  const result = {text:'worker-ocr',confidence:0.9};
  self.postMessage({id, result});
});