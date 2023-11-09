import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="speech"
export default class extends Controller {
  // static targets = ["name"];

  speak() {
    this.image_id = this.data.get("id");
    this.name = this.data.get("label");
    // const element = this.nameTarget;
    // const name = element.value;
    const utterance = new SpeechSynthesisUtterance(this.name);
    utterance.pitch = 1.5;
    utterance.volume = 0.5;
    utterance.rate = 1;

    speechSynthesis.speak(utterance);
    this.postToAPI();
  }

  postToAPI() {
    fetch(`/response_images/${this.image_id}/click`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        label: this.name,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          window.location.href = data.redirect_url;
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
