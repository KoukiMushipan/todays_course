module ResponseApiMethods
  extend ActiveSupport::Concern

  def pickup_address(result)
    result['features'][0]['properties']['place_name'].split(', ').last
  end

  def normal_result?(result)
    result['type'] == "FeatureCollection" && result['features'].count > 0
  end

  def pickup_coordinates(result)
    arr = result['features'][0]['geometry']['coordinates']
    {latitude: arr[1], longitude: arr[0]}
  end
end
