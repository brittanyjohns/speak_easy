import { Controller } from "@hotwired/stimulus";

import Cropper from "cropperjs";

// Connects to data-controller="images"
export default class extends Controller {
  static targets = ["source", "output", "cropButton"];
  connect() {
    console.log("Connected to images controller ***");
    this.createCropper();
  }

  createCropper() {
    this.cropper = new Cropper(this.sourceTarget);
    const element = this.cropper.getCropperSelection();
    console.log(element);
    element.aspectRatio = 1;
    element.initialAspectRatio = 1;
  }

  click = (e) => {
    console.log("click");
    e.preventDefault();

    this.cropper
      .getCropperSelection()
      .$toCanvas()
      .then((canvas) => {
        this.outputTarget.src = canvas.toDataURL();
        this.postToAPI(canvas.toDataURL());
      })
      .catch((error) => {
        // Handle errors, notify the user
        console.error("Error:", error);
      });
  };

  postToAPI(croppedData) {
    const image_id = this.data.get("id");
    const dataURL = croppedData;
    const strippedData = dataURL.replace(/^data:image\/[a-z]+;base64,/, "");
    fetch(`/croppable/${image_id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        image: {
          cropped_image: strippedData,
        },
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          window.location.href = data.redirect_url;
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
