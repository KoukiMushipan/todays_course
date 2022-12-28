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
    locations = search_nearby_published_comment(radius)
    locations_info = locations.map {|location| location.attributes_for_show_comment}

    duplication = locations_info.group_by {|location_info| location_info[:fixed][:place_id]}.select { |k, v| v.size > 1 }
    locations_info.uniq! {|d| d[:fixed][:place_id]}

    duplication.each do |k, v|
      comments = v.map {|d| d[:fixed][:comment]}
      locations_info.find {|d| k == d[:fixed][:place_id]}[:fixed][:comment] = comments
    end

    locations_info.sample(20)
  end

  def search_nearby_published_comment(radius)
    published_comment_locations = Location.joins(:destination).where(destination: {is_published_comment: true}).where.not(destination: {comment: true})
    nearby_locations = published_comment_locations.where(search_range(latitude, longitude, radius))
    nearby_locations.includes(:destination)
  end

  def attributes_for_show_comment
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
        comment: destination.comment,
      }
    }
  end
end
