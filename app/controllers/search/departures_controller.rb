class Search::DeparturesController < ApplicationController
  def new
    @search_departure = SearchDepartureForm.new

    @departures = current_user.departures.where(is_saved: true).includes(:location).order(created_at: :desc)
    @histories = current_user.histories.includes(destination: [departure: :location], destination: :location).order(created_at: :desc)
  end

  def create
    @search_departure = SearchDepartureForm.new(search_departure_params)
    if !@search_departure.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def search_departure_params
    params.require(:search_departure_form).permit(:name, :address, :is_saved)
  end
end
