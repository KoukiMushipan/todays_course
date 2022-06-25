function initMap() {
  let markers = [];
  let infoWindow = [];
  const departure = gon.searchInfo['departure']
  const radius = gon.searchInfo['radius']
  const recommendations = gon.searchInfo['recommendations'];
  const coordinates = { lat: departure['latitude'], lng: departure['longitude'] };

  function calcZoom(radius) {
    let n = radius - 1000
    n = 14.2 - n / 100 * 0.06;
    return Math.round(n * 10) / 10;
  }

  const map = new google.maps.Map(document.getElementById('map'), {
    center: coordinates,
    zoom: calcZoom(radius)
  });

  const departureMarker = new google.maps.Marker({
    map: map,
    position: coordinates,
    icon: '/marker/marker-departure.png'
  });

  for (let i = 0; i < recommendations.length; i++) {
    const markerCoordinates = new google.maps.LatLng({ lat: recommendations[i]['latitude'], lng: recommendations[i]['longitude'] });
    markers[i] = new google.maps.Marker({
      position: markerCoordinates,
      map: map,
      icon: `/marker/marker-destination${i}.png`
    });

    infoWindow[i] = new google.maps.InfoWindow({
      content: `${recommendations[i]['name']}<br>${recommendations[i]['address']}<br><a class="text-blue-700" href="/destinations/new?id=${i}" data-turbo="false">ルート表示</a>`
    });
    markerEvent(i);
  }

  function markerEvent(i) {
    markers[i].addListener('click', function () {
      infoWindow[i].open(map, markers[i]);
      for (let n = 0; n < recommendations.length; n++) {
        if (n === i) {
          continue;
        }
        infoWindow[n].close();
      }
    });
  }

  let departureInfoWindow = new google.maps.InfoWindow({
    content: departure['name'] + '<br>' + departure['address']
  });

  departureMarker.addListener('click', function () {
    departureInfoWindow.open(map, departureMarker);
  });

  var circle = new google.maps.Circle({
    map: map,
    center: coordinates,
    radius: radius
  });

  circle.setOptions({
    fillColor: '#f0ffff',
    strokeColor: '#87cefa'
  });
}
