class Search::Departure
  include ActiveModel::Model
  include RequestApiMethods
  include ResponseApiMethods

  attr_accessor :id, :name, :address, :latitude, :longitude, :is_saved

  validates :name, length: { maximum: 50 }
  validates :address, presence: true, length: { maximum: 255 }

  def self.new_and_valid(search_departure_params)
    search_departure = Search::Departure.new(search_departure_params)
    search_departure.valid?
    search_departure
  end

  def request_reverse_geocoder
    url = create_reverse_geocoder_url
    result = request_api(url)
    normal_result?(result)
  end

  def request_geocoder
    url = create_geocoder_url
    result = request_api(url)
    if normal_result?(result)
      result
    else
      error_message = I18n.t 'process.failed_get_location'
      errors.add(:address, error_message)
      false
    end
  end

  def create_reverse_geocoder_url
    query = longitude + ',' + latitude
    URI(Settings.mapbox.reverse_url_front + query + Settings.mapbox.reverse_url_rear)
  end

  def create_geocoder_url
    query = URI.encode_www_form_component(address)
    URI(Settings.mapbox.forward_url_front + query + Settings.mapbox.forward_url_rear)
  end

  def set_current_location_info(result)
    self.name = I18n.t 'process.get_current_location'
    self.address = pickup_address(result)
  end

  def set_coordinates_and_address(result)
    coordinates = pickup_coordinates(result)
    self.latitude = coordinates[:latitude]
    self.longitude = coordinates[:longitude]

    address = pickup_address(result)
    self.address = address
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
