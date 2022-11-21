import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delete"
export default class extends Controller {
  oneWayDistance() {
    console.log('読み込んだよ') // 開発用
    const showDistance = document.getElementById('js-show-distance');
    if (showDistance) {
      showDistance.remove();
    }
  }
}
