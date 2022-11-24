import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ['menu', 'closeButton', 'openButton'];

  openOrClose() {
    this.menuTarget.classList.toggle('hidden');
    this.openButtonTarget.classList.toggle('hidden');
    this.closeButtonTarget.classList.toggle('hidden');
  }
}
