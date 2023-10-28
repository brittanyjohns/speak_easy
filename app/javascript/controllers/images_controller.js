import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="images"
export default class extends Controller {
  static targets = ["id"];
  destroy() {
    const element = this.element;
    const target = this.idTarget;
    const id = target.value;
    console.log(
      `element: ${JSON.stringify(
        element,
        null,
        2
      )}\nid: ${id} - target: ${target}`
    );
    const token = document.querySelector('meta[name="csrf-token"]').content;
    const url = `/images/${id}`;

    fetch(url, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          element.remove();
        } else {
          alert("Something went wrong");
        }
      });
  }
}
