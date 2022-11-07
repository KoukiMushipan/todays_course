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
    full_address = result[:formatted_address].split(' ')
    full_address.shift
    {
      name: name,
      latitude: result[:geometry][:location][:lat],
      longitude: result[:geometry][:location][:lng],
      address: full_address.join(' '),
      place_id: result[:place_id]
    }
  end
end
