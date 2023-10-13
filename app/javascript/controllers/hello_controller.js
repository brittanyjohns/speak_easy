import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!";
  }
}

const draggable = document.getElementById("draggable");
const dropzone = document.getElementById("dropzone");

draggable.addEventListener("dragstart", (event) => {
  event.dataTransfer.setData("text/plain", draggable.id);
});

dropzone.addEventListener("dragover", (event) => {
  event.preventDefault(); // Prevent default to allow drop
});

dropzone.addEventListener("drop", (event) => {
  event.preventDefault();
  const id = event.dataTransfer.getData("text/plain");
  const draggableElement = document.getElementById(id);
  dropzone.appendChild(draggableElement);
});

const sortableList = document.getElementById("sortable-list");
Sortable.create(sortableList);
