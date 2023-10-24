import { Controller } from "@hotwired/stimulus";
// import { FetchRequest } from "@rails/request.js";

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
  alert(`You dropped: ${id}`);
  myMethod();

  dropzone.appendChild(draggableElement);
});

const sortableList = document.getElementById("sortable-list");
Sortable.create(sortableList);

// const myMethod = async () => {
//   const request = new FetchRequest("post", "localhost:3000/posts", {
//     body: JSON.stringify({ name: "Request.JS" }),
//   });
//   const response = await request.perform();
//   console.log(response);
//   if (response.ok) {
//     const body = await response.text;
//   }
// };
