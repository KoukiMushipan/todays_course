module ResponseApiMethods
  extend ActiveSupport::Concern

  def pickup_address(result)
    address = result['features'][0]['properties']['place_name']
    if address.include?(', ')
      result['features'][0]['properties']['place_name'].split(', ').last
    else
      result['features'][0]['properties']['place_name'].split(' ').last
    end
  end

  def normal_result?(result)
    result['type'] == "FeatureCollection" && result['features'].count > 0
  end

  def pickup_coordinates(result)
    arr = result['features'][0]['geometry']['coordinates']
    {latitude: arr[1], longitude: arr[0]}
  end

  def set_coordinates_and_address(search_departure, result)
    coordinates = pickup_coordinates(result)
    search_departure.set_coordinates(coordinates)

    address = pickup_address(result)
    search_departure.address = address
  end
end
