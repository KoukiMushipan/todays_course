window.showRoute = () => {
  const departure = gon.locationInfo.departure;
  const destination = gon.locationInfo.destination;
  let destinationName
  let destinationAddress

  if (destination.fixed && destination.variable) {
    destinationName = destination.variable.name;
    destinationAddress = destination.fixed.address;
  } else {
    destinationName = destination.name;
    destinationAddress = destination.address;
  }

  const directionsService = new google.maps.DirectionsService();
  const directionsRenderer = new google.maps.DirectionsRenderer();

  const map = new google.maps.Map(document.getElementById('map'), {
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: false,
    gestureHandling: "greedy",
  });

  directionsRenderer.setMap(map);

  const request = {
    origin: departure.address,
    destination: destinationAddress,
    travelMode: 'WALKING'
  };

  directionsService.route(request, function (result, status) {
    if (status == 'OK') {
      result['routes'][0]['legs'][0]['start_address'] = departure.name;
      result['routes'][0]['legs'][0]['end_address'] = destinationName;

      directionsRenderer.setDirections(result);

      if (document.getElementById('js-input-area')) {
        const distance = result['routes'][0]['legs'][0]['distance']['value'];
        document.getElementById('js-show-distance').textContent = `片道: ${distance}m`;
        document.getElementById('destination_form_name').value = destinationName;
        document.getElementById('destination_form_distance').value = distance;
      }
    }
  });
}
