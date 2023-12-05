import { Controller } from "@hotwired/stimulus";
function removeParamFromURL(url, param) {
  const urlObj = new URL(url);
  urlObj.searchParams.delete(param);
  return urlObj.toString();
}
// Connects to data-controller="search-form"
export default class extends Controller {
  static targets = ["query", "userImagesOnly", "imageIdsToAdd"];
  static values = { useronly: String };
  connect() {
    this.queryTarget.value = this.data.get("query-value");

    const currentUrl = window.location.href;
    const url = new URL(currentUrl);
    const params = new URLSearchParams(url.search);
    this.userImagesOnlyTarget.checked = params.has("user_images_only", "1");
  }

  search = (e) => {
    this.queryTarget.focus();

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 200);
  };
}
