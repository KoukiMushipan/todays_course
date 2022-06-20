class Search::Departure
  include ActiveModel::Model
  attr_accessor :name, :address, :latitude, :longitude, :id, :is_saved

  def create_reverse_geocoder_url
    query = longitude + ',' + latitude
    URI(Settings.mapbox.reverse_url_front + query + Settings.mapbox.reverse_url_rear)
  end

  def create_geocoder_url
    query = URI.encode_www_form_component(address)
    URI(Settings.mapbox.forward_url_front + query + Settings.mapbox.forward_url_rear)
  end

  def set_coordinates(coordinates)
    self.latitude = coordinates[:latitude]
    self.longitude = coordinates[:longitude]
  end

  def make_hash_for_location
    if name.blank?
      {address: address, latitude: latitude, longitude: longitude}
    else
      {name: name, address: address, latitude: latitude, longitude: longitude}
    end
  end

  def will_save?
    is_saved == '1'
  end
end
