class Search::Recommend
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend RequestApiMethods
  extend ResponseApiMethods

  attribute :name, :string
  attribute :address, :string
  attribute :latitude, :float
  attribute :longitude, :float
  attribute :distance, :integer
  attribute :score, :integer

  def self.create_recommendations(local_search_results, radius)
    recommendations = new_and_set_locations(local_search_results)
    matrix_results = request_matrix(local_search_results[:departure], recommendations)
    return false unless matrix_results
    recommendations.each_with_index do |r, n|
      r.set_distance(matrix_results[n], radius)
    end
    create_recommendations_for_session(recommendations)
  end

  def self.new_and_set_locations(results)
    arr = []
    parameters = pickup_parameters_for_recommend(results)
    parameters.each do |parameter|
      arr << new(parameter)
    end
    arr
  end

  def self.request_matrix(departure, recommendations)
    url = create_matrix_url(departure, recommendations)
    results = request_api(url)
    return false unless normal_martix_results?(results)
    distances = pickup_distances(results)
  end

  def self.create_recommendations_for_session(recommendations)
    recommendations.sort_by!(&:score)
    recommendations.pop(recommendations.length - 5) if recommendations.length > 5
    arr = []
    recommendations.each do |recommendation|
      arr << recommendation.attributes
    end
    arr
  end

  def create_query_for_matrix
    ";#{longitude},#{latitude}"
  end

  def set_distance(distance, radius)
    self.distance = distance
    score = self.distance - radius
    self.score = score.abs
  end
end
