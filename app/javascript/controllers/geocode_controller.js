import { Controller } from "@hotwired/stimulus"
import toastr from "toastr";

// Connects to data-controller="geocode"
export default class extends Controller {
  static targets = ['form', 'get', 'loading'];
  static values = { url: String };
  static classes = ['load'];

  initialize() {
    toastr.options = {
      "closeButton": true,
    }

    const toggleLoadingText = () => {
      this.getTarget.classList.toggle(this.loadClass)
      this.loadingTarget.classList.toggle(this.loadClass)
    };

    window.initMap = () => {
      const success = (position) => {
        const geocoder = new google.maps.Geocoder();
        const latLng = { lat: parseFloat(position.coords.latitude), lng: parseFloat(position.coords.longitude) }

        geocoder.geocode({ location: latLng })
          .then((response) => {
            if (response.results[0]) {
              this.formTarget.value = response.results[0].formatted_address.split(' ').pop();
              toastr.success('現在地を取得しました');
              this.loadingTarget.classList.toggle(this.loadClass);
            } else {
              toastr.error('対応する住所が見つかりませんでした');
              toggleLoadingText();
            }
          })
          .catch(() => {
            toastr.error('住所の検索に失敗しました');
            toggleLoadingText();
          });
      };

      const error = () => {
        toastr.error('現在地取得に失敗しました');
        toggleLoadingText();
      };

      this.getTarget.addEventListener('click', (e) => {
        e.preventDefault();
        toggleLoadingText();
        navigator.geolocation.getCurrentPosition(success, error);
      })
    }

    const script = document.createElement('script');
    script.src = this.urlValue;
    document.body.appendChild(script);
  }
}
