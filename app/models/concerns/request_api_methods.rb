module RequestApiMethods
  extend ActiveSupport::Concern

  def request_api(url)
    json_result = Net::HTTP.get(url)
    JSON.parse(json_result)
  end

  def create_matrix_url(departure, recommendations)
    query = "#{departure['longitude']},#{departure['latitude']}"
    recommendations.each do |recommendation|
      query << recommendation.create_query_for_matrix
    end
    URI(Settings.mapbox.matrix_url_front + query + Settings.mapbox.matrix_url_rear)
  end
end
