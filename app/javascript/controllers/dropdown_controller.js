import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['menu', 'closeButton', 'openButton'];

  open() {
    this.menuTarget.classList.remove('hidden');
    this.openButtonTarget.classList.add('hidden');
    this.closeButtonTarget.classList.remove('hidden');
  }

  close() {
    this.menuTarget.classList.add('hidden');
    this.openButtonTarget.classList.remove('hidden');
    this.closeButtonTarget.classList.add('hidden');
  }
}
