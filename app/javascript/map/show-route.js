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

      const distance = result['routes'][0]['legs'][0]['distance']['value'];
      const showDistance = document.getElementById('js-show-distance')
      const destinationNameForm = document.getElementById('destination_form_name')
      const destinationDistanceForm = document.getElementById('destination_form_distance')

      if (showDistance) {
        showDistance.textContent = `片道: ${distance}m`;
      }
      if (destinationNameForm) {
        destinationNameForm.value = destinationName;
      }

      if (destinationDistanceForm) {
        destinationDistanceForm.value = distance;
      }
    }
  });
}
