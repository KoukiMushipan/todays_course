import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delete"
export default class extends Controller {
  oneWayDistance() {
    const showDistance = document.getElementById('js-show-distance');
    if (showDistance) {
      showDistance.remove();
    }
  }
}
