import { Controller } from "@hotwired/stimulus"
import toastr from "toastr";

// Connects to data-controller="toast"
export default class extends Controller {
  static values = { type: String, message: String }
  connect() {
    toastr.options = {
      "closeButton": true,
    }

    if (this.typeValue === 'success') {
      toastr.success(this.messageValue);
    } else if (this.typeValue === 'error') {
      toastr.error(this.messageValue);
    }
  }
}
