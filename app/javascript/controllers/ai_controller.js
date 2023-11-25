import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ai"
export default class extends Controller {
  static targets = ["enable"];
  connect() {
    this.aiEnabled = this.data.get("mode");
    this.enabledGlobal = this.data.get("enabled-global");
    if (this.enabledGlobal === "true") {
      if (this.aiEnabled === "true") {
        this.enableTarget.checked = true;
      } else {
        this.enableTarget.checked = false;
      }
    } else {
      this.enableTarget.disabled = true;
      // this.enableTarget.classList.add("hidden");
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
