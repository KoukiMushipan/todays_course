class RequestGeocodeService
  include RequestApi

  def initialize(departure_form)
    @departure_form = departure_form
  end

  def call
    return {error: '入力情報に誤りがあります'} if !departure_form.valid?

    result = request_geocode
    check_result(result) ? parse_result(result) : {error: '位置情報の取得に失敗しました'}
  end

  private

  attr_reader :departure_form

  def request_geocode
    encode_address = {address: departure_form.address}.to_query
    url = Settings.google.geocode_url + encode_address
    send_request(url)
  end

  def parse_address(result)
    full_address = result[:results][0][:formatted_address].split(' ')
    full_address.shift
    full_address.join(' ')
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
      place_id: result[:results][0][:place_id]
    }
  end
end
