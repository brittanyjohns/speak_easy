import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="static-board"
export default class extends Controller {
  static targets = ["list"];
  connect() {
    console.log(this.listTarget);
  }
  clearList() {
    this.listTarget.innerHTML = "";
  }
  speakList() {
    const utterance = new SpeechSynthesisUtterance(this.listTarget.innerText);
    utterance.pitch = 1.5;
    utterance.volume = 0.7;
    utterance.rate = 1;
    speechSynthesis.speak(utterance);
  }
}
