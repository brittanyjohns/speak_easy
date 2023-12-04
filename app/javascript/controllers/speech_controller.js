import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="speech"
export default class extends Controller {
  connect() {
    this.send_to_ai = this.data.get("send-to-ai");
    this.word_list = this.data.get("word-list");
    this.name = this.data.get("label");
    this.nextEndpoint = this.data.get("next-endpoint");
  }

  speak() {
    this.image_id = this.data.get("id");
    console.log(
      ` ${this.image_id} ${this.name} ${this.send_to_ai} - ${this.nextEndpoint}`
    );
    const utterance = new SpeechSynthesisUtterance(this.name);
    utterance.pitch = 1.5;
    utterance.volume = 0.5;
    utterance.rate = 1;

    speechSynthesis.speak(utterance);
    if (this.send_to_ai === "true") {
      this.sendToAI();
    } else {
      console.log(`Getting next board or image: ${this.nextEndpoint}`); // Look at local_names.default
      this.getNext();
    }
  }

  getNext() {
    fetch(`/${this.nextEndpoint}/${this.image_id}/next`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(`data:${data}`); // Look at local_names.default
        if (data.status === "success") {
          console.log("Success:", data);
          if (data.redirect_url) {
            window.location.href = data.redirect_url;
          } else {
            window.location.reload();
          }
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  sendToAI() {
    fetch(`/${this.nextEndpoint}/${this.image_id}/click`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        label: this.name,
        word_list: this.word_list,
        situation: this.situation,
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
