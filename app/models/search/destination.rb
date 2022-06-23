class Search::Destination
  include ShareSearch

  attribute :distance, :integer

  def self.create_from_recommendation(recommendation)
    new(name: recommendation['name'], address: recommendation['address'], latitude: recommendation['latitude'], longitude: recommendation['longitude'])
  end

end
