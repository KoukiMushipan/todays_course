class Search::Destination
  include ActiveModel::Model

  attr_accessor :name, :address, :latitude, :longitude, :distance, :is_saved, :radius, :gc

  validates :radius, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 5000}
  validates :gc, presence: true
  validate :have_gc?

  def have_gc?
    if !Settings.yahoo.gc.to_h.values.include?(gc)
      errors.add(:gc, "は指定されたものから選択してください")
    end
  end

  def self.create_from_recommendation(recommendation)
    new(name: recommendation['name'], address: recommendation['address'], latitude: recommendation['latitude'], longitude: recommendation['longitude'])
  end

  def create_local_search_url(departure)
    dist = radius.to_f / 1000
    query = {lat: departure['latitude'], lon: departure['longitude'], dist: dist, gc: gc}.to_query
    URI(Settings.yahoo.local_search_url + query)
  end
end
