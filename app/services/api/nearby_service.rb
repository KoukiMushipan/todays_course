module Api
  class NearbyService
    include Api::Request
    include CalculateLocations

    def initialize(departure_info, search_term_form)
      @departure_info, @search_term_form = departure_info, search_term_form
    end

    def call
      results = calculation
      results ? parse_results(results) : false
    end

    private

    attr_reader :departure_info, :search_term_form

    def calculation
      locations = three_locations_for_nearby_request(departure_info, search_term_form.radius)

      locations.each_with_index do |location, index|
        radius = radius_for_nearby_request(search_term_form.radius, index)
        results = request_nearby(location, radius)
        return results[:results] if results[:status] == 'OK'
      end
      false
    end

    def request_nearby(location_info, radius)
      parse_location = "#{location_info[:latitude]},#{location_info[:longitude]}"
      encode_parameters = { location: parse_location, radius:, type: search_term_form.type }.to_query
      url = Settings.google.nearby_url + encode_parameters
      send_request(url)
    end

    def parse_results(results)
      results.map do |result|
        latitude = result[:geometry][:location][:lat]
        longitude = result[:geometry][:location][:lng]
        address = result[:vicinity].tr('０-９ａ-ｚＡ-Ｚ．＠−', '0-9a-zA-Z.@-').gsub(/\d(ー)/, '-')
        place_id = result[:place_id]

        variable = { uuid: SecureRandom.uuid, name: result[:name] }
        fixed = { latitude:, longitude:, address:, place_id: }

        { variable:, fixed: }
      end
    end
  end
end
