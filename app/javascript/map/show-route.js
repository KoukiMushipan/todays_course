window.showRoute = () => {
  const departure = gon.locationInfo.departure;
  const destination = gon.locationInfo.destination;

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
    destination: destination.fixed.address,
    travelMode: 'WALKING'
  };

  directionsService.route(request, function (result, status) {
    if (status == 'OK') {
      result['routes'][0]['legs'][0]['start_address'] = departure.name;
      result['routes'][0]['legs'][0]['end_address'] = destination.variable.name;

      directionsRenderer.setDirections(result);

      const distance = result['routes'][0]['legs'][0]['distance']['value'];
      document.getElementById('js-show-distance').textContent = `片道: ${distance}m`;
      document.getElementById('destination_form_name').value = destination.variable.name;
      document.getElementById('destination_form_distance').value = distance;
    }
  });
}
