import { Controller } from "@hotwired/stimulus";
import Tesseract from "tesseract.js";

// Connects to data-controller="ocr"
export default class extends Controller {
  static targets = ["file", "image_description"];
  connect() {
    console.log("Hello, Stimulus!", this.element);
  }

  upload(event) {
    event.preventDefault();

    let file = this.fileTarget.files[0];
    let reader = new FileReader();

    reader.onload = (event) => {
      Tesseract.recognize(event.target.result, "eng", {
        logger: (m) => console.log(m),
      }).then(({ data: { text } }) => {
        this.image_descriptionTarget.value = text;
      });
    };
    reader.readAsArrayBuffer(file);
  }
}