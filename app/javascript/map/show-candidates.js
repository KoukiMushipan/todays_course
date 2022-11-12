window.showCandidates = () => {
  const departure = gon.searchInfo.departure;
  const center = { lat: departure.latitude, lng: departure.longitude }
  const results = gon.searchInfo.results;
  const radius = gon.searchInfo.search_term.radius;

  const map = new google.maps.Map(document.getElementById('map'), {
    center,
    zoom: 14.5,
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: false
  });

  new google.maps.Circle({
    map,
    center,
    radius,
    clickable: false,
    fillColor: '#f0ffff',
    strokeColor: '#87cefa'
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
      lat: parseFloat(location.fixed.latitude),
      lng: parseFloat(location.fixed.longitude)
    });

    const marker = new google.maps.Marker({
      position: coordinatesMarker,
      map,
      icon: 'https://maps.google.com/mapfiles/ms/icons/yellow-dot.png'
    });

    marker.addListener('click', () => {
      openInfoWindow(location, marker)
    });

    marker.locationUuid = location.variable.uuid
    return marker
  };

  let infoWindow;
  const openInfoWindow = (location, marker) => {
    if (infoWindow) {
      infoWindow.close();
    }
    infoWindow = new google.maps.InfoWindow({
      content: `${location.variable.name}<br><a href="/destinations/new?destination=${location.variable.uuid}">目的地に設定</a>`
    });
    infoWindow.open(map, marker);
  }

  let markers = results.map((result) => setMarker(result));
  openInfoWindow(results[0], markers[0]);

  const swiperWrapper = document.getElementsByClassName('swiper-wrapper')[0]
  const activeSlideObservation = new MutationObserver(() => {
    if (swiperWrapper.style.cssText.includes('transition-duration: 0ms;')) {
      const activeSlideLocationUuid = document.getElementsByClassName('swiper-slide-active')[0].id.replace('js-result-', '')
      const activeSlideMarker = markers.find((marker) => marker.locationUuid === activeSlideLocationUuid);
      const activeSlideLocation = results.find((result) => result.variable.uuid === activeSlideLocationUuid);
      openInfoWindow(activeSlideLocation, activeSlideMarker);
    }
  });
  activeSlideObservation.observe(swiperWrapper, {
    attributes: true
  });
}
