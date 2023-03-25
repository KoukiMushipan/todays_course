class PickCandidatesService
  include CalculateLocations

  def initialize(user, results, departure_info, search_term)
    @user, @results, @departure_info, @search_term = user, results, departure_info, search_term
  end

  def call
    nearby_destinations = search_nearby_destinations

    nearby_commented_info = acquisition_commented_info(nearby_destinations).sample(20)
    nearby_own_info = acquisition_own_info(nearby_destinations).sample(20)

    pick_candidates = { results:, nearby_commented_info:, nearby_own_info: }
    prepare_pick_candidates(pick_candidates)
  end

  private

  attr_reader :user, :results, :departure_info, :search_term

  def acquisition_commented_info(destinations)
    commented_destinations = search_commented_destinations(destinations)
    commented_destinations_info = commented_destinations.map(&:attributes_for_comment)
    summarize_comments(commented_destinations_info)
  end

  def search_commented_destinations(destinations)
    destinations.where.not(user:)
                .where.not(comment: nil)
                .where(is_published_comment: true, is_saved: true)
  end

  def summarize_comments(destinations_info)
    place_id_group = destinations_info.group_by { |destination_info| destination_info[:fixed][:place_id] }
    duplication = place_id_group.select { |_k, v| v.size > 1 }

    destinations_info.uniq! { |destination_info| destination_info[:fixed][:place_id] }

    duplication.each do |k, v|
      target_destination = destinations_info.find { |destination_info| k == destination_info[:fixed][:place_id] }
      target_destination[:fixed][:comment] = v.map { |destination_info| destination_info[:fixed][:comment] }
    end

    destinations_info
  end

  def acquisition_own_info(destinations)
    own_destinations = destinations.where(user:, is_saved: true)
    own_destinations.map(&:attributes_for_own)
  end

  def search_nearby_destinations
    radius = search_term[:radius] + 1000
    search_range = calculate_search_range(departure_info[:latitude], departure_info[:longitude], radius)
    Destination.includes(:location).where(location: search_range)
  end

  def prepare_pick_candidates(pick_candidates)
    pick_candidates = remove_duplicates(pick_candidates)
    pick_candidates.each { |_k, candidates| candidates.sample(20) }
    pick_candidates.merge!({ departure_info:, search_term: })
    pick_candidates
  end

  def remove_duplicates(pick_candidates)
    place_id_arr = []
    pick_candidates.each do |_k, candidates|
      candidates.delete_if { |candidate| place_id_arr.include?(candidate[:fixed][:place_id]) }
      place_id_arr += candidates.map { |candidate| candidate[:fixed][:place_id] }
    end

    pick_candidates
  end
end
