class Search::Departure
  include ShareSearch

  def request_reverse_geocoder
    url = create_reverse_geocoder_url
    result = request_api(url)
    return false unless normal_geocoder_result?(result)
    result
  end

  def request_geocoder
    url = create_geocoder_url
    result = request_api(url)
    return false unless normal_geocoder_result?(result)
    result
  end

  def create_reverse_geocoder_url
    query = longitude.to_s + ',' + latitude.to_s
    URI(Settings.mapbox.reverse_url_front + query + Settings.mapbox.reverse_url_rear)
  end

  def create_geocoder_url
    query = URI.encode_www_form_component(address)
    URI(Settings.mapbox.forward_url_front + query + Settings.mapbox.forward_url_rear)
  end

  def set_current_location_info(result)
    self.name = I18n.t('process.get_current_location')
    self.address = pickup_address(result)
  end

  def set_coordinates_and_address(result)
    coordinates = pickup_coordinates(result)
    self.latitude = coordinates[:latitude]
    self.longitude = coordinates[:longitude]

    address = pickup_address(result)
    self.address = address
  end

  def create_departure_and_set
    departure = Departure.create_departure_and_location_by_search(self)
    self.attributes = departure.set_search_departure.attributes
  end

  def make_hash_for_location
    if name.blank?
      {address: address, latitude: latitude, longitude: longitude}
    else
      {name: name, address: address, latitude: latitude, longitude: longitude}
    end
  end
end
