class DestinationsController < ApplicationController
  def new
    @destination = session[:results].find {|result| result[:id] == params[:id].to_i}
    if !@destination
      redirect_to search_destinations_path, flash: {error: "目的地が見つかりませんでした"}
    end
  end
end
