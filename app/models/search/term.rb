class Search::Term
  include ActiveModel::Model
  include ActiveModel::Attributes
  include RequestApiMethods
  include ResponseApiMethods

  attribute :radius, :integer
  attribute :gc, :string

  validates :radius, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 5000}
  validates :gc, presence: true, inclusion: { in: Settings.yahoo.gc.to_h.values }

  def request_local_search(departure)
    url = create_local_search_url(departure)
    results = request_api(url)
    if normal_local_search_results?(results)
      results[:departure] = departure.compact
      results
    else
      false
    end
  end

  def create_local_search_url(departure)
    dist = radius.to_f / 1000
    query = {lat: departure['latitude'], lon: departure['longitude'], dist: dist, gc: gc}.to_query
    URI(Settings.yahoo.local_search_url + query)
  end
end
