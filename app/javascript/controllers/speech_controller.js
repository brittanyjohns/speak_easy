import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="speech"
export default class extends Controller {
  // static targets = ["name"];
  connect() {
    this.send_to_ai = this.data.get("send-to-ai");
    this.word_list = this.data.get("word-list");
    console.log(`send_to_ai: ${this.send_to_ai}`);
    console.log(`word_list: ${this.word_list}`);
  }

  speak() {
    this.image_id = this.data.get("id");
    this.name = this.data.get("label");
    // this.send_to_ai = this.data.get("send-to-ai");
    console.log(` ${this.image_id} ${this.name} ${this.send_to_ai}`);
    // const element = this.nameTarget;
    // const name = element.value;
    const utterance = new SpeechSynthesisUtterance(this.name);
    utterance.pitch = 1.5;
    utterance.volume = 0.5;
    utterance.rate = 1;

    speechSynthesis.speak(utterance);
    if (this.send_to_ai === "true") {
      this.sendToAI();
    }
  }

  sendToAI() {
    fetch(`/response_images/${this.image_id}/click`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        label: this.name,
        word_list: this.word_list,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(`data:${data}`); // Look at local_names.default
        if (data.status === "success") {
          console.log("Success:", data);
          window.location.href = data.redirect_url;
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
