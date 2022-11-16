class RequestGeocodeService
  include RequestApi

  def initialize(departure_form)
    @departure_form = departure_form
  end

  def call
    return {error: '入力情報に誤りがあります'} if !departure_form.valid?

    result = request_geocode
    result[:status] == 'OK' ? parse_result(result) : {error: '位置情報の取得に失敗しました'}
  end

  private

  attr_reader :departure_form

  def request_geocode
    encode_address = {address: departure_form.address}.to_query
    url = Settings.google.geocode_url + encode_address
    send_request(url)
  end

  def parse_result(result)
    result = result[:results][0]
    full_address = result[:formatted_address].split(' ')
    full_address.shift
    {
      name: departure_form.name,
      latitude: result[:geometry][:location][:lat],
      longitude: result[:geometry][:location][:lng],
      address: full_address.join(' '),
      place_id: result[:place_id]
    }
  end
end
