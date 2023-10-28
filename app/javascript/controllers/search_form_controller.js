import { Controller } from "@hotwired/stimulus";
function removeParamFromURL(url, param) {
  const urlObj = new URL(url);
  urlObj.searchParams.delete(param);
  return urlObj.toString();
}
// Connects to data-controller="search-form"
export default class extends Controller {
  static targets = ["query", "user_images_only"];
  connect() {}

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      console.log(this.element);
      this.element.requestSubmit();
    }, 200);
  }

  user_images_only() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      console.log(this.element);
      this.element.requestSubmit();
      console.log("submitted: ", this.element);
      const currentUrl = window.location.href;
      console.log("currentUrl: ", currentUrl);
      // window.location.replace(newUrl);
      const url = new URL(currentUrl);
      const baseUrl = url.origin + url.pathname;
      const params = new URLSearchParams(url.search);
      console.log(`Query string (before):\t ${params}`);
      if (params.has("user_images_only", "0")) {
        console.log("user_images_only exists");
        params.delete("user_images_only", "0");
        const newUrl = baseUrl + "?" + params.toString();
        // window.location.replace(newUrl);
        console.log(`Query string (after):\t ${params}`);
      } else {
        console.log("user_images_only does not exist");
        params.append("user_images_only", "0");
        const newUrl = baseUrl + "?" + params.toString();
        // window.location.replace(newUrl);
        console.log(`Query string (after):\t ${params}`);
      }
    }, 200);
  }
}
