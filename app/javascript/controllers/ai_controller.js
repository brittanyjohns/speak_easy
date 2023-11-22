import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ai"
export default class extends Controller {
  static targets = ["enable"];
  connect() {
    this.aiEnabled = this.data.get("mode");
    if (this.aiEnabled === "true") {
      this.enableTarget.checked = true;
    }
  }

  toggle() {
    this.enableTarget.checked = !this.enableTarget.checked;
    this.updateAi(this.enableTarget.checked);
  }

  updateAi = (aiEnabled) => {
    fetch("/ai", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ ai: { enabled: aiEnabled } }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          this.updateUi(data.ai_enabled);
        } else {
          console.log("Failure:", data);
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  };

  updateUi = (aiEnabled) => {
    console.log(`updateUi: ${aiEnabled}`);
    this.aiEnabled = aiEnabled;
    this.data.set("mode", aiEnabled);
    this.enableTarget.checked = aiEnabled;
    console.log(`enableTarget: ${this.enableTarget}`);
  };
}
