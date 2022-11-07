class DestinationsController < ApplicationController
  def new
    @destination_info = session[:results].find {|result| result[:id] == params[:id].to_i}
    if @destination_info
      gon.locationInfo = {departure: session[:departure], destination: @destination_info}
    else
      redirect_to search_destinations_path, flash: {error: "目的地が見つかりませんでした"}
    end
  end
end
