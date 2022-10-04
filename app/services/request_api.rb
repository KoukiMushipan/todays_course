module RequestApi

  private

  def send_request(url)
    uri = URI.parse(url)
    json = Net::HTTP.get(uri)
    data_list = JSON.parse(json, symbolize_names: true)
  end
end
