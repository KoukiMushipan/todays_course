class RequestNearbyService
  include RequestApi
  include CalculateThreeLocations

  def initialize(departure_info, search_term_form)
    @departure_info, @search_term_form = departure_info, search_term_form
  end

  def call
    return {error: '入力情報に誤りがあります'} if !search_term_form.valid?

    results = calculation
    results ? parse_results(results) : {error: '目的地が見つかりませんでした'}
  end

  private

  attr_reader :departure_info, :search_term_form

  def calculation
    locations_for_request = create_locations_for_request(search_term_form.radius, departure_info)

    locations_for_request.each_with_index do |location_for_request, index|
      radius_for_request = create_radius_for_request(search_term_form.radius, index)
      results = request_nearby(location_for_request, radius_for_request)
      return results[:results] if results[:status] == 'OK'
    end
    false
  end

  def request_nearby(location_for_request, radius_for_request)
    encode_parameters = {location: parse_location(location_for_request), radius: radius_for_request, type: search_term_form.type}.to_query
    url = Settings.google.nearby_url + encode_parameters
    send_request(url)
  end

  def parse_location(location_for_request)
    "#{location_for_request[:latitude]},#{location_for_request[:longitude]}"
  end

  def parse_results(results)
    results.map do |result|
      {
        variable:
        {
          uuid: SecureRandom.uuid,
          name: result[:name],
        },
        fixed:
        {
          latitude: result[:geometry][:location][:lat],
          longitude: result[:geometry][:location][:lng],
          address: result[:vicinity],
          place_id: result[:place_id]
        }
      }
    end
  end
end
