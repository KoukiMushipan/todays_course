module Api
  module Request
    private

    def send_request(url)
      uri = URI.parse(url)
      json = Net::HTTP.get(uri)
      JSON.parse(json, symbolize_names: true)
    end
  end
end
