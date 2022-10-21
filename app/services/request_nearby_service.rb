class RequestNearbyService
  include RequestApi
  include CalculateThreeLocations

  def initialize(location, radius, type)
    @location = location
    @radius = radius
    @type = type
  end

  def call
    results = calculation
    results ? parse_results(results) : results
  end

  private

  attr_reader :location, :radius, :type

  def calculation
    locations_for_request = create_locations_for_request(radius, location)

    locations_for_request.each_with_index do |location_for_request, index|
      radius_for_request = create_radius_for_request(radius, index)
      results = request_nearby(location_for_request, radius_for_request)
      return results[:results] if results[:status] == 'OK'
    end
    false
  end

  def request_nearby(location_for_request, radius_for_request)
    encode_parameters = {location: parse_location(location_for_request), radius: radius_for_request, type: type}.to_query
    url = Settings.google.nearby_url + encode_parameters
    send_request(url)
  end

  def parse_location(location_for_request)
    "#{location_for_request[:latitude]},#{location_for_request[:longitude]}"
  end

  def parse_results(results)
    results.map.with_index do |result, index|
      {
        id: index,
        name: result[:name],
        latitude: result[:geometry][:location][:lat],
        longitude: result[:geometry][:location][:lng],
        address: result[:vicinity],
        place_id: result[:place_id]
      }
    end
  end
end
