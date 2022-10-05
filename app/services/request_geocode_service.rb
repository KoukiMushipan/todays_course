class RequestGeocodeService
  include RequestApi

  def initialize(name, address)
    @name = name
    @address = address
  end

  def call
    result = request_geocode
    return false if result[:status] != 'OK'
    parse_result(result)
  end

  private

  attr_reader :name, :address

  def request_geocode
    encode_address = {address: address}.to_query
    url = Settings.google.geocode_url + encode_address
    send_request(url)
  end

  def parse_result(result)
    result = result[:results][0]
    {
      name: name,
      latitude: result[:geometry][:location][:lat],
      longitude: result[:geometry][:location][:lng],
      address: address,
      place_id: result[:place_id]
    }
  end
end
