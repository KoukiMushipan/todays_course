class Search::Recommend
  include ActiveModel::Model
  attr_accessor :name, :address, :latitude, :longitude, :distance, :score

  def self.set_locations(results)
    arr = []
    results['Feature'].each do |result|
      coordinates = result['Geometry']['Coordinates'].split(',')
      arr << new(name: result['Name'], address: result['Property']['Address'], latitude: coordinates[1], longitude: coordinates[0])
    end
    arr
  end

  def set_distance(distance, radius)
    self.distance = distance.to_i

    score = self.distance - radius.to_i
    self.score = score.abs
  end
end
