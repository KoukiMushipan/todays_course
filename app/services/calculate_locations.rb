module CalculateLocations
  include Math

  private

  def three_theta
    theta = rand(1..90)
    [theta, theta + 120, theta + 240].shuffle
  end

  def calculate_latitude(latitude, radius, theta)
    (360 * radius) / (2 * PI * 6356752.314) * sin(theta * PI / 180.0) + latitude
  end

  def calculate_longitude(latitude, longitude, radius, theta)
    (360 * radius) / ((6378137.0 * cos(latitude * PI / 180)) * 2 * PI) * cos(theta * PI / 180.0) + longitude
  end

  def search_range(latitude, longitude, radius)
    south_latitude = calculate_latitude(latitude, radius, 270)
    north_latitude = calculate_latitude(latitude, radius, 90)

    west_longitude = calculate_longitude(latitude, longitude, radius, 180)
    east_longitude = calculate_longitude(latitude, longitude, radius, 0)

    {latitude: south_latitude..north_latitude, longitude: west_longitude..east_longitude}
  end

  def three_locations_for_nearby_request(location, radius)
    three_theta.map do |tt|
      latitude = calculate_latitude(location[:latitude], radius, tt)
      longitude = calculate_longitude(location[:latitude], location[:longitude], radius, tt)
      {latitude: latitude, longitude: longitude}
    end
  end

  def radius_for_nearby_request(radius, index)
    search_radius = radius * 2 / 6 * (index + 1)
    search_radius > 500 ? search_radius : 500
  end
end
