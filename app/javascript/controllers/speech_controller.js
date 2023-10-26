import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="speech"
export default class extends Controller {
  static targets = ["name"];

  speak() {
    const element = this.nameTarget;
    const name = element.value;
    const utterance = new SpeechSynthesisUtterance(name);
    utterance.pitch = 1.5;
    utterance.volume = 0.5;
    utterance.rate = 1;

    speechSynthesis.speak(utterance);
    console.log("Done.");
  }
}
