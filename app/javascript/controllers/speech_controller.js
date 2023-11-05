import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="speech"
export default class extends Controller {
  static targets = ["name"];

  speak() {
    const name = this.data.get("label");
    console.log(`name: ${name}`);
    // const element = this.nameTarget;
    // const name = element.value;
    const utterance = new SpeechSynthesisUtterance(name);
    utterance.pitch = 1.5;
    utterance.volume = 0.5;
    utterance.rate = 1;

    speechSynthesis.speak(utterance);
    this.postToAPI();
    console.log("Done.");
  }

  postToAPI() {
    const image_id = this.data.get("id");
    fetch(`/response_images/${image_id}/click`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      // body: JSON.stringify({
      //   image: {
      //     cropped_image: strippedData,
      //   },
      // }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          alert("CLICKED");
          // window.location.href = data.redirect_url;
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
