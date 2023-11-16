import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="selection-form"
export default class extends Controller {
  static targets = ["query", "array"];

  connect() {
    this.query_value = this.data.get("query-value");

    console.log(
      `this.queryTarget.value: ${this.queryTarget.value} - this.query_value: ${this.query_value}`
    );
  }

  selection = (e) => {
    console.log(
      `Selection event: ${this.queryTarget.value}\narray: ${this.arrayTarget.value}`
    );
  };

  send = (e) => {
    console.log(`Submit event: ${JSON.stringify(e)}`);

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 200);
  };
}
