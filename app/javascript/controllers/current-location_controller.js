import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  getLoction() {
    const success = (position) => {
      document.getElementById('js-get-latitude').value = position.coords.latitude
      document.getElementById('js-get-longitude').value = position.coords.longitude
      document.getElementById('js-location-submit').click();
    }

    const error = () => {
      alert('現在地の取得に失敗しました。');
    }

    navigator.geolocation.getCurrentPosition(success, error);
  }
}
