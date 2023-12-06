import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="static-image"
export default class extends Controller {
  static targets = ["wrapper"];
  connect() {
    this.label = this.data.get("label");
    this.thelistOutlet = document.querySelector("#the-list");
  }

  speak() {
    if (this.wrapperTarget.classList.contains("bg-green-200")) {
      this.removeFromList();
    } else {
      this.addToList(this.label);
      const utterance = new SpeechSynthesisUtterance(this.label);

      utterance.pitch = 1.5;
      utterance.volume = 0.7;
      utterance.rate = 1;
      speechSynthesis.speak(utterance);
    }
  }

  click() {
    if (this.wrapperTarget.classList.contains("bg-green-200")) {
      this.removeFromList();
    } else {
      this.addToList(this.label);
    }
  }

  addToList(word) {
    console.log(`this.thelistOutlet: ${this.thelistOutlet}`);
    console.log(`word: ${word}`);
    this.wrapperTarget.classList.add("bg-green-200");
    this.thelistOutlet.innerHTML += `<li class="mr-4">${word}</li>`;
  }

  removeFromList() {
    this.wrapperTarget.classList.remove("bg-green-200");
    const listItems = this.thelistOutlet.querySelectorAll("li");
    listItems.forEach((item) => {
      if (item.innerText === this.label) {
        item.remove();
      }
    });
  }
}
