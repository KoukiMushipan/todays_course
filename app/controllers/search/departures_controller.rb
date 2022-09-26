class Search::DeparturesController < ApplicationController
  def new
    @departures = current_user.departures.where(is_saved: true).includes(:location).order(created_at: :desc)
    @histories = current_user.histories.includes(destination: [departure: :location], destination: :location).order(created_at: :desc)
  end

  def create
  end
end
