import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";

// Connects to data-controller="images"
export default class extends Controller {
  static targets = ["source", "output", "cropButton"];
  connect() {
    console.log("Connected");
    console.log(this.sourceTarget);
    this.createCropper();
    this.sourceTarget.addEventListener("load", () => {
      console.log("Image loaded");
    });
  }

  createCropper() {
    this.cropper = new Cropper(this.sourceTarget, {
      background: true,
      aspectRatio: 1,
      viewMode: 1,
      // dragMode: "move",
      responsive: true,
      checkCrossOrigin: false,
    });
    // this.cropper = new Cropper(this.sourceTarget, {
    //   dragMode: "move",
    //   aspectRatio: 16 / 9,
    //   autoCropArea: 0.65,
    //   restore: false,
    //   guides: false,
    //   center: false,
    //   highlight: false,
    //   cropBoxMovable: false,
    //   cropBoxResizable: false,
    //   toggleDragModeOnDblclick: false,
    // });
  }

  click = (e) => {
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
    console.log(`image_id: ${image_id}`);
    const dataURL = croppedData;
    console.log(`dataURL:  ${dataURL.length} - ${typeof dataURL}`);
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
