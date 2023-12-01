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
    this.query_value = this.data.get("query-value");
    this.queryTarget.value = this.query_value;
    console.log(`imageIdsToAdd: ${this.imageIdsToAddTarget.value}`);
    console.log(`queryValue: ${this.query_value}`);
    const currentUrl = window.location.href;
    const url = new URL(currentUrl);
    const params = new URLSearchParams(url.search);
    console.log(`params: ${params}`);
    this.userImagesOnlyTarget.checked = params.has("user_images_only", "1");
    this.queryTarget.focus();
  }

  search = (e) => {
    this.queryTarget.focus();

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 200);
  };
}
