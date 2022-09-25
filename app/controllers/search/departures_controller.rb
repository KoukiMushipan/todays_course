class Search::DeparturesController < ApplicationController
  def new
    @departures = current_user.departures.where(is_saved: true)
    @histories = current_user.histories.includes(destination: :departure)
  end

  def create
  end
end
