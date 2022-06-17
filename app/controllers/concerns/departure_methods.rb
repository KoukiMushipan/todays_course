module DepartureMethods
  extend ActiveSupport::Concern

  def set_departure(user, session_departure)
    departure = Departure.set_or_create(user, session_departure)
    session[:departure] = departure.set_search_departure
    departure
  end
end
