class RequestNearbyService
  include RequestApi

  def initialize(location, radius, type)
    @location = location
    @radius = radius
    @type = type
  end

  def call
    result = request_nearby
    return false if result[:status] != 'OK'
    parse_result(result)
  end

  private

  attr_reader :location, :radius, :type

  def request_nearby
    encode_parameters = {location: parse_location, radius: radius, type: type}.to_query
    url = Settings.google.nearby_url + encode_parameters
    send_request(url)
  end

  def parse_location
    "#{location[:latitude]},#{location[:longitude]}"
  end

  def parse_result(result)
    result = result[:results]
    # {
    #   name: name,
    #   latitude: result[:geometry][:location][:lat],
    #   longitude: result[:geometry][:location][:lng],
    #   address: address,
    #   place_id: result[:place_id]
    # }
  end
end
