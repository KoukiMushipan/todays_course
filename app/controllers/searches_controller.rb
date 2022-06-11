class SearchesController < ApplicationController
  def destination
    @departure = session[:departure]
  end

  def candidates
  end

  def route
  end
end
