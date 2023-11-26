import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="checkbox-select-all"
export default class extends Controller {
  static targets = ["parent1", "child1", "count", "parent2", "child2"];
  connect() {
    // set all to false on page refresh
    this.child1Targets.map((x) => (x.checked = false));
    this.child2Targets.map((x) => (x.checked = false));
    this.parent1Target.checked = false;
    this.parent2Target.checked = false;
    this.countTarget.innerHTML = 0;
  }

  toggleChildren1() {
    this.toggleChildren("parent1");
  }

  toggleChildren2() {
    this.toggleChildren("parent2");
  }

  toggleChildren(targetType) {
    this.parentTarget = this.parent1Target;
    this.childTargets = this.child1Targets;
    if (targetType == "parent2") {
      this.parentTarget = this.parent2Target;
      this.childTargets = this.child2Targets;
    }

    if (this.parentTarget.checked) {
      this.childTargets.map((x) => (x.checked = true));
    } else {
      this.childTargets.map((x) => (x.checked = false));
    }
    this.updateCount();
  }

  toggleParent1() {
    this.toggleParent("parent1");
  }

  toggleParent2() {
    this.toggleParent("parent2");
  }

  toggleParent(targetType) {
    this.parentTarget = this.parent1Target;
    this.childTargets = this.child1Targets;
    if (targetType == "parent2") {
      this.parentTarget = this.parent2Target;
      this.childTargets = this.child2Targets;
    }

    if (this.childTargets.map((x) => x.checked).includes(false)) {
      this.parentTarget.checked = false;
    } else {
      this.parentTarget.checked = true;
    }
    this.updateCount();
  }

  updateCount() {
    const count1 = this.child1Targets.filter((x) => x.checked).length;
    const count2 = this.child2Targets.filter((x) => x.checked).length;
    this.countTarget.innerHTML = count1 + count2;
  }
}
