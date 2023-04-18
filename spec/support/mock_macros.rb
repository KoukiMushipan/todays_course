module MockMacros
  def geocode_mock(result)
    geocode = instance_double(Api::GeocodeService, call: result)
    allow(Api::GeocodeService).to receive(:new).and_return(geocode)
  end

  def nearby_mock(result)
    nearby =
      if result.instance_of?(Hash)
        instance_double(Api::NearbyService, call: [result])
      else
        instance_double(Api::NearbyService, call: result)
      end
    allow(Api::NearbyService).to receive(:new).and_return(nearby)
  end
end
