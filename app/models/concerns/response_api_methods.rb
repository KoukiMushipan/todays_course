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

  def pickup_coordinates(result)
    arr = result['features'][0]['geometry']['coordinates']
    {latitude: arr[1], longitude: arr[0]}
  end

  def pickup_parameters_for_recommend(results)
    arr = []
    results['Feature'].each do |result|
      coordinates = result['Geometry']['Coordinates'].split(',')
      arr << {name: result['Name'], address: result['Property']['Address'], latitude: coordinates[1], longitude: coordinates[0]}
    end
    arr
  end

  def pickup_distances(results)
    arr = results['distances'][0]
    arr.shift
    arr.map(&:to_i)
  end

  def normal_geocoder_result?(result)
    result['type'] == "FeatureCollection" && result['features'].count > 0
  end

  def normal_local_search_results?(results)
    results['ResultInfo']['Status'] == 200 && results['ResultInfo']['Count'] > 0
  end

  def normal_martix_results?(results)
    results['code'] == "Ok" && results['distances'][0].count > 0
  end
end
