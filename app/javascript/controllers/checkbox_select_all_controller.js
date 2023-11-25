import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="checkbox-select-all"
export default class extends Controller {
  static targets = ["parent", "child", "count"];
  connect() {
    // set all to false on page refresh
    this.childTargets.map((x) => (x.checked = false));
    this.parentTarget.checked = false;
    this.countTarget.innerHTML = 0;
  }

  toggleChildren() {
    if (this.parentTarget.checked) {
      this.childTargets.map((x) => (x.checked = true));
    } else {
      this.childTargets.map((x) => (x.checked = false));
    }
    this.updateCount();
  }

  toggleParent() {
    if (this.childTargets.map((x) => x.checked).includes(false)) {
      this.parentTarget.checked = false;
    } else {
      this.parentTarget.checked = true;
    }
    this.updateCount();
  }

  updateCount() {
    this.countTarget.innerHTML = this.childTargets.filter(
      (x) => x.checked == true
    ).length;
  }
}
