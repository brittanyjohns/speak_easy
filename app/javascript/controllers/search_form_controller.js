import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search-form"
export default class extends Controller {
  connect() {}

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      console.log(this.element);
      this.element.requestSubmit();
      console.log("submitted: ", this.element);
    }, 200);
  }
}
