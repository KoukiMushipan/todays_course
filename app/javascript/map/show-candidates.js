window.showCandidates = () => {
  const departure = gon.searchInfo.departure;
  const center = { lat: departure.latitude, lng: departure.longitude }
  const results = gon.searchInfo.results;
  const commented_destinations = gon.searchInfo.commented_destinations
  const radius = gon.searchInfo.search_term.radius;
  const path = location.pathname;

  const map = new google.maps.Map(document.getElementById('map'), { // 表示するマップの作成
    center,
    zoom: 14.5,
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: false
  });

  new google.maps.Circle({ // 表示するサークルの作成
    map,
    center,
    radius,
    clickable: false,
    fillColor: '#f0ffff',
    strokeColor: '#87cefa'
  });

  const departureMarker = new google.maps.Marker({ // 出発地のマーカー作成
    map,
    position: center,
  });

  let departureInfoWindow = new google.maps.InfoWindow({ // 出発地マーカーのinfo window作成
    content: `出発地<br>${departure.name}`
  });
  departureMarker.addListener('click', () => {
    departureInfoWindow.open(map, departureMarker);
  });
  departureInfoWindow.open(map, departureMarker);

  const setMarker = (location, markerColor) => { // マーカーをセットする関数
    const coordinatesMarker = new google.maps.LatLng({
      lat: parseFloat(location.fixed.latitude),
      lng: parseFloat(location.fixed.longitude)
    });

    const marker = new google.maps.Marker({
      position: coordinatesMarker,
      map,
      icon: `/${markerColor}-marker.png`
    });

    marker.addListener('click', () => {
      openInfoWindow(location, marker)
    });

    marker.locationUuid = location.variable.uuid
    return marker
  };

  let infoWindow; // info windowは出発地を覗いて1つしか開かないようにするための変数
  const openInfoWindow = (location, marker) => { // マーカーにinfo windowをつける関数
    if (infoWindow) {
      infoWindow.close();
    }

    let content;
    if (path.includes('gest')) {
      content = location.variable.name;
    } else {
      content = `${location.variable.name}<br><a href="/destinations/new?destination=${location.variable.uuid}">目的地に設定</a>`;
      if (location.fixed.comment) {
        content += '<br>《comment》'
        if (Array.isArray(location.fixed.comment)) {
          location.fixed.comment.forEach(e => content += `<br>・${e}`)
        } else {
          content += `<br>・${location.fixed.comment}`
        }
      }
    }

    infoWindow = new google.maps.InfoWindow({
      content
    });

    infoWindow.open(map, marker);
  }

  let markers = []
  markers[0] = results.map((result) => setMarker(result, 'orange')); // resultsの一つ一つにマーカーを作成
  markers[1] = commented_destinations.map((commented_destination) => setMarker(commented_destination, 'teal')); // commented_destinationsの一つ一つにマーカーを作成
  let candidates = [results, commented_destinations]

  for (let i = 0; i < document.getElementsByClassName('swiper-wrapper').length; i++) { // slideとinfo windowが連動するための記述
    const swiperWrapper = document.getElementsByClassName('swiper-wrapper')[i]
    const activeSlideObservation = new MutationObserver(() => {
      if (swiperWrapper.style.cssText.includes('transition-duration: 0ms;')) {
        const activeSlideLocationUuid = document.getElementsByClassName('swiper-slide-active')[i].id.replace('js-result-', '')
        const activeSlideMarker = markers[i].find((marker) => marker.locationUuid === activeSlideLocationUuid);
        const activeSlideLocation = candidates[i].find((result) => result.variable.uuid === activeSlideLocationUuid);
        openInfoWindow(activeSlideLocation, activeSlideMarker);
      }
    });

    activeSlideObservation.observe(swiperWrapper, {
      attributes: true
    });
  }
}
