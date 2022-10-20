class Search::DestinationsController < ApplicationController
  def index
  end

  def new
    departure = Departure.find_by(uuid: params[:departure])
    if departure
      @departure_info, session[:departure] = Array.new(2, departure.attributes_for_session)
      @search_destination = SearchDestinationForm.new
    elsif session[:departure]
      @departure_info = session[:departure]
      @search_destination = SearchDestinationForm.new
    else
      redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"}
    end
  end

  def create
    @search_destination = SearchDestinationForm.new(search_destination_params)

    if !@search_destination.valid?
      @departure_info = session[:departure]
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    result = RequestNearbyService.new(session[:departure], @search_destination.radius, @search_destination.type).call
    if !result
      @departure_info = session[:departure]
      flash.now[:error] = '目的地が見つかりませんでした'
      return render :new, status: :unprocessable_entity
    end

    # if @search_destination.is_saved
    #   destination = current_user.destinations.create!(is_saved: true, location: Location.create!(result))
    #   redirect_to new_search_destination_path(destination: destination.uuid), flash: {success: "出発地を保存しました"}
    # else
    #   session[:destination] = result
    #   redirect_to new_search_destination_path
    # end
  end

  private

  def search_destination_params
    params.require(:search_destination_form).permit(:radius, :type)
  end
end
