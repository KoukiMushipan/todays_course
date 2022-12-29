class Location < ApplicationRecord
  include CalculateLocations

  has_one :departure, dependent: :destroy
  has_one :destination, dependent: :destroy

  accepts_nested_attributes_for :destination

  validates :name, presence: true, length: { maximum: 50 }
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :address, presence: true, length: { maximum: 255 }

  def search_nearby_published_comment_info(radius)
    locations_info = search_nearby_published_comment(radius).map do |location|
      info = location.attributes_for_map
      info[:fixed][:comment] = location.destination.comment
      info
    end

    wrap_comments(locations_info)
    locations_info.sample(20)
  end

  def search_nearby_own_info(radius, user)
    search_nearby_own(radius, user).map do |location|
      info = location.attributes_for_map
      info[:fixed][:created_at] = location.destination.created_at
      info
    end
  end

  def attributes_for_map
    {
    variable:
      {
        uuid: SecureRandom.uuid,
        name: name,
      },
    fixed:
      {
        latitude: latitude,
        longitude: longitude,
        address: address,
        place_id: place_id,
      }
    }
  end

  private

  def wrap_comments(locations_info)
    duplication = locations_info.group_by {|location_info| location_info[:fixed][:place_id]}.select { |k, v| v.size > 1 }
    locations_info.uniq! {|d| d[:fixed][:place_id]}

    duplication.each do |k, v|
      comments = v.map {|d| d[:fixed][:comment]}
      locations_info.find {|d| k == d[:fixed][:place_id]}[:fixed][:comment] = comments
    end
  end

  def search_nearby_published_comment(radius)
    published_comment_locations = Location.joins(:destination).where(destination: {is_published_comment: true}).where.not(destination: {comment: true})
    search_nearby_destinations(published_comment_locations, radius)
  end

  def search_nearby_own(radius, user)
    own_destinations = Location.joins(:destination).where(destination: {user: user})
    search_nearby_destinations(own_destinations, radius).sample(20)
  end

  def search_nearby_destinations(locations, radius)
    locations.where(search_range(latitude, longitude, radius)).includes(:destination)
  end
end
