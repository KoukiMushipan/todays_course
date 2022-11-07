module CalculateThreeLocations
  include Math

  private

  def three_theta
    theta = rand(1..90)
    [theta, theta + 120, theta + 240].shuffle
  end

  def create_locations_for_request(radius, location)
    three_theta.map do |tt|
      latitude = (360 * radius) / (2 * PI * 6356752.314) * sin(tt * PI / 180.0) + location[:latitude]
      longitude = (360 * radius) / ((6378137.0 * cos(location[:latitude] * PI / 180)) * 2 * PI) * cos(tt * PI / 180.0) + location[:longitude]
      {latitude: latitude, longitude: longitude}
    end
  end

  def create_radius_for_request(radius, index)
    search_radius = radius * 2 / 6 * (index + 1)
    search_radius > 500 ? search_radius : 500
  end
end
