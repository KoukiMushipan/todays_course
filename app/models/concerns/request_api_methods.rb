module RequestApiMethods
  extend ActiveSupport::Concern

  def request_api(url)
    json_result = Net::HTTP.get(url)
    JSON.parse(json_result)
  end

  def pickup_distances(results)
    arr = results['distances'][0]
    arr.shift
    arr
  end

  def calc_distance_and_set(recommendations, radius)
    url = create_matrix_url(recommendations)
    results = request_api(url)

    distances = pickup_distances(results)
    n = 0

    recommendations.each do |r|
      r.set_distance(distances[n], radius)
      n += 1
    end
  end

  def create_matrix_url(recommendations)
    query = "#{session[:departure]['longitude']},#{session[:departure]['latitude']}"
    recommendations.each do |recommendation|
      query << ";#{recommendation.longitude},#{recommendation.latitude}"
    end
    URI(Settings.mapbox.matrix_url_front + query + Settings.mapbox.matrix_url_rear)
  end

  def sort_pop_set(recommendations)
    recommendations.sort_by!{ |r| r.score }
    recommendations.pop(recommendations.length - 5) if recommendations.length > 5
    session[:recommendations] = recommendations
  end
end
