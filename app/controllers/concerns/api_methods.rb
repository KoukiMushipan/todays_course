module ApiMethods
  extend ActiveSupport::Concern

  def request_api(url)
    json_result = Net::HTTP.get(url)
    JSON.parse(json_result)
  end

  def extract_address(result)
    result['features'][0]['properties']['place_name'].split(', ').last
  end

  def extract_coordinates(result)
    arr = result['features'][0]['geometry']['coordinates']
    {latitude: arr[1], longitude: arr[0]}
  end
end
