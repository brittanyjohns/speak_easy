import { Controller } from "@hotwired/stimulus";
import Tesseract from "tesseract.js";

// Connects to data-controller="ocr"
export default class extends Controller {
  static targets = ["file", "image_description", "submit_button"];
  connect() {
    this.submit_buttonTarget.disabled = true;
    console.log("Hello, OCR!!", this.submit_buttonTarget.value);
  }

  upload(event) {
    event.preventDefault();
    this.submit_buttonTarget.disabled = true;
    this.submit_buttonTarget.value = "Parsing...";


    let file = this.fileTarget.files[0];
    let reader = new FileReader();

    reader.onload = (event) => {
      Tesseract.recognize(event.target.result, "eng", {
        logger: (m) => console.log(m),
      }).then(({ data: { text } }) => {
        this.image_descriptionTarget.value = text;
        this.submit_buttonTarget.disabled = false;
        this.submit_buttonTarget.value = "Save";

      });
    };
    reader.readAsArrayBuffer(file);
    this.submit_buttonTarget.disabled = false;
  }

  submitButtons() {
    console.log("submitButtons");
    return this.element.querySelectorAll("input[type='submit']");
  }
}