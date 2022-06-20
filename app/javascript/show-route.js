let aaa
let distance
const departure = gon.routeInfo['departure']
const destination = gon.routeInfo['destination']

function initMap() {
  var directionsService = new google.maps.DirectionsService();
  var directionsRenderer = new google.maps.DirectionsRenderer();
  var home = new google.maps.LatLng(parseFloat(departure['latitude']), parseFloat(departure['longitude']));
  var mapOptions = {
    zoom: 14,
    center: home
  }
  var map = new google.maps.Map(document.getElementById('map'), mapOptions);
  directionsRenderer.setMap(map);

  var request = {
    origin: departure.address,
    destination: destination.address,
    travelMode: 'WALKING'
  };

  directionsService.route(request, function (result, status) {
    if (status == 'OK') {
      result['routes'][0]['legs'][0]['start_address'] = departure['name']
      result['routes'][0]['legs'][0]['end_address'] = destination['name']
      directionsRenderer.setDirections(result);
      distance = result['routes'][0]['legs'][0]['distance']['value']
      document.getElementById('js-show-distance').textContent = `片道: ${distance}m`
      document.getElementById('js-get-distance').value = distance * 2
    }
  });
}
