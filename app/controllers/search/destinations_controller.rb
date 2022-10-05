class Search::DestinationsController < ApplicationController
  def index
  end

  def new
    @departure_info = session[:departure]
  end

  def create
  end
end
