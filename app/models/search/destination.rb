class Search::Destination
  include ShareSearch

  attribute :distance, :integer

  validates :distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 42195}

  def self.create_from_recommendation(recommendation)
    new(name: recommendation['name'], address: recommendation['address'], latitude: recommendation['latitude'], longitude: recommendation['longitude'])
  end

  def make_hash_for_location
    if name.blank?
      {address: address, latitude: latitude, longitude: longitude}
    else
      {name: name, address: address, latitude: latitude, longitude: longitude}
    end
  end

  def make_hash_for_destination
    {distance: distance, is_saved: is_saved}
  end
end
