import toastr from "toastr";

window.getCurrentLocation = () => {
  const button = document.getElementById('js-get-current-location-button');
  const loading = document.getElementById('js-loading-text');
  const form = document.getElementById('departure_form_address') || document.getElementById('guest_form_address');

  toastr.options = {
    "closeButton": true,
  }

  const toggleLoadingText = () => {
    button.classList.toggle('hidden')
    loading.classList.toggle('hidden')
  };

  const success = (position) => {
    const geocoder = new google.maps.Geocoder();
    const latLng = { lat: parseFloat(position.coords.latitude), lng: parseFloat(position.coords.longitude) }

    geocoder.geocode({ location: latLng, region: 'JP' })
      .then((response) => {
        if (response.results[0]) {
          form.value = response.results[0].formatted_address.split(' ').pop();
          toastr.success('現在地を取得しました');
          loading.classList.toggle('hidden');
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

  button.addEventListener('click', (e) => {
    e.preventDefault();
    toggleLoadingText();
    navigator.geolocation.getCurrentPosition(success, error);
  })
}
