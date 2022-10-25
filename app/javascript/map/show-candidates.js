window.showCandidates = () => {
  const departure = gon.searchInfo.departure;
  const center = { lat: departure.latitude, lng: departure.longitude }
  const results = gon.searchInfo.results;

  const map = new google.maps.Map(document.getElementById('map'), {
    center,
    zoom: 14.5,
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: false
  });

  const departureMarker = new google.maps.Marker({
    map,
    position: center,
  });

  let departureInfoWindow = new google.maps.InfoWindow({
    content: `出発地<br>${departure.name}`
  });
  departureMarker.addListener('click', () => {
    departureInfoWindow.open(map, departureMarker);
  });
  departureInfoWindow.open(map, departureMarker);

  const setMarker = (location) => {
    const coordinatesMarker = new google.maps.LatLng({
      lat: parseFloat(location.latitude),
      lng: parseFloat(location.longitude)
    });

    const marker = new google.maps.Marker({
      position: coordinatesMarker,
      map,
      icon: 'https://maps.google.com/mapfiles/ms/icons/yellow-dot.png'
    });

    marker.addListener('click', () => {
      openInfoWindow(location, marker)
    });

    // marker.locationId = location.id
    // return marker
  };

  let infoWindow;
  const openInfoWindow = (location, marker) => {
    if (infoWindow) {
      infoWindow.close();
    }
    infoWindow = new google.maps.InfoWindow({
      content: `${location.name}<br><a href="/search/destinations/${location.id}">目的地に設定</a>`
    });
    infoWindow.open(map, marker);
  }

  let markers = results.map((result) => setMarker(result));
}
