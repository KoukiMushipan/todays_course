module Api
  class GeocodeService
    include Api::Request

    def initialize(departure_form)
      @departure_form = departure_form
    end

    def call
      result = request_geocode
      check_result(result) ? parse_result(result) : false
    end

    private

    attr_reader :departure_form

    def request_geocode
      encode_address = { address: departure_form.address }.to_query
      url = Settings.google.geocode_url + encode_address
      send_request(url)
    end

    def pick_address(result)
      result[:results][0][:formatted_address]
    end

    def parse_address(result)
      address = pick_address(result).match(/.*[\d１-９]{3}[-ー−][\d１-９]{4}\s*(.+)/)
      return false unless address[1].match(/.+[\d１-９]{1,4}[-ー丁−]{1}.{0,2}[\d０-９].*/)

      address[1].tr('０-９ａ-ｚＡ-Ｚ．＠ー−-', '0-9a-zA-Z.@-')
    end

    def check_result(result)
      result[:status] == 'OK' && parse_address(result).present?
    end

    def parse_result(result)
      {
        name: departure_form.name,
        latitude: result[:results][0][:geometry][:location][:lat],
        longitude: result[:results][0][:geometry][:location][:lng],
        address: parse_address(result),
        place_id: result[:results][0][:place_id],
        is_saved: departure_form.is_saved
      }
    end
  end
end
