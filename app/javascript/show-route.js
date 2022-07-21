function initMap() {
  const departure = gon.routeInfo['departure'];
  const destination = gon.routeInfo['destination'];

  const directionsService = new google.maps.DirectionsService();
  const directionsRenderer = new google.maps.DirectionsRenderer();
  const departureCoordinates = new google.maps.LatLng(departure['latitude'], departure['longitude']);

  const map = new google.maps.Map(document.getElementById('map'), {
    center: departureCoordinates
  });

  directionsRenderer.setMap(map);

  const request = {
    origin: departure.address,
    destination: destination.address,
    travelMode: 'WALKING'
  };

  directionsService.route(request, function (result, status) {
    if (status == 'OK') {
      result['routes'][0]['legs'][0]['start_address'] = departure['name']
      result['routes'][0]['legs'][0]['end_address'] = destination['name']
      directionsRenderer.setDirections(result);
      const distance = result['routes'][0]['legs'][0]['distance']['value'];
      document.getElementById('js-show-distance').textContent = `片道: ${distance}m`;
      if (document.getElementById('js-get-distance') != undefined) {
        document.getElementById('js-get-distance').value = distance;
      };
    }
  });
}
