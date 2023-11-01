import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";

// Connects to data-controller="upload"
// NOT_IN_USE - for reference only
export default class extends Controller {
  static targets = [
    "input",
    "preview",
    "output",
    "cropButton",
    "submitCroppedButton",
    "form",
  ];
  connect() {
    console.log("Connected to upload controller");
    // this.formTarget.addEventListener("load", () => {
    //   console.log("Form loaded");
    //   console.log(this.formTarget);
    // });
    this.inputTarget.addEventListener("load", () => {
      console.log("Input loaded");
      console.log(this.inputTarget);
    });
    this.inputTarget.addEventListener("change", (e) => {
      console.log("Input changed");
      console.log(e.target.files[0]);
      console.log(`this: ${this}`);
      this.previewImage();
    });
    console.log(`*previewTarget: ${JSON.stringify(this.previewTarget)}`);
    this.previewTarget.addEventListener("load", () => {
      console.log("Preview loaded");
      console.log(this.formTarget);
      this.createCropper();
    });
  }

  previewImage() {
    console.log("Previewing image");
    console.log(this.inputTarget);
    console.log(this.inputTarget.files[0]);
    const reader = new FileReader();
    let previewTarget = this.previewTarget;
    reader.onload = function (e) {
      console.log("reader loaded");
      console.log(`Preview target: ${previewTarget}`);
      previewTarget.src = e.target.result;
    };
    reader.readAsDataURL(this.inputTarget.files[0]);
  }

  createCropper() {
    console.log(
      `createCropper previewTarget: ${JSON.stringify(this.previewTarget)}`
    );
    this.cropper = new Cropper(this.previewTarget, {
      background: true,
      aspectRatio: 1,
      viewMode: 1,
      // dragMode: "move",
      responsive: true,
      checkCrossOrigin: false,
    });
    // this.cropper = new Cropper(this.previewTarget, {
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

    this.outputTarget.src = this.cropper
      .getCropperSelection()
      .$toCanvas()
      .then((canvas) => {
        console.log("cropped canvas");

        this.outputTarget.src = canvas.toDataURL();

        // this.postToAPI(canvas.toDataURL());
      });
  };

  onFormSubmit = (e) => {
    e.preventDefault();
    console.log(`onFormSubmit: ${JSON.stringify(this.element)}`);
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      // this.element.requestSubmit();
    }, 200);
  };

  submitCropped = (e) => {
    e.preventDefault();
    console.log(`submitCropped: ${JSON.stringify(this.element)}`);
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      // this.element.requestSubmit();
    }, 200);
  };
}
