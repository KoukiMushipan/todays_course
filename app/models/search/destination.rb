class Search::Destination
  include ShareSearch

  attribute :distance, :integer

  def self.create_from_recommendation(recommendation)
    new(name: recommendation['name'], address: recommendation['address'], latitude: recommendation['latitude'], longitude: recommendation['longitude'])
  end

  def create_local_search_url(departure)
    dist = radius.to_f / 1000
    query = {lat: departure['latitude'], lon: departure['longitude'], dist: dist, gc: gc}.to_query
    URI(Settings.yahoo.local_search_url + query)
  end
end
