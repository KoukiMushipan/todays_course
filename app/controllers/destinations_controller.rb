class DestinationsController < ApplicationController
  def new
    return redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !session[:departure]

    return redirect_to new_search_destination_path, flash: {error: "条件を入力してください"} if !session[:results]

    @result = session[:results].find {|result| result[:variable][:uuid] == params[:destination]}
    if @result
      @destination = DestinationForm.new
      gon.locationInfo = {departure: session[:departure], destination: @result}
    else
      redirect_to search_destinations_path, flash: {error: "目的地が見つかりませんでした"}
    end
  end

  def create
    debugger
    return redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !session[:departure]

    return redirect_to new_search_destination_path, flash: {error: "条件を入力してください"} if !session[:results]

    result = session[:results].find {|result| result[:variable][:uuid] == params[:destination]}
    return redirect_to search_destinations_path, flash: {error: "目的地を選択してください"} if !result

    @destination = DestinationForm.new(destination_params)
    if !@destination.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    if @destination.is_saved && session[:departure][:uuid]
      @departure = Departure.find_by!(uuid: session[:departure][:uuid])
      location = Location.create!(result[:fixed].merge(name: @destination.name))
      @destination_info = Destination.create!(departure: departure, location: location, distance: @destination.distance, is_saved: true).attributes_for_session
      session[:destination] = @destination_info
    elsif @destination.is_saved && !session[:departure][:uuid]
      @departure = current_user.departures.create!(is_saved: false, location: Location.create!(session[:departure]))
      location = Location.create!(result[:fixed].merge(name: @destination.name))
      @destination_info = Destination.create!(departure: departure, location: location, distance: @destination.distance, is_saved: true).attributes_for_session
      session[:destination] = @destination_info
    else
      @destination_info = @destination.attributes.select {|k,v| k == 'name' || k == 'distance'}
      @destination_info.merge!(result[:fixed])
      session[:destination] = @destination_info
    end

    # redirect_to new_history_path(departure: @departure.uuid, destination: @destination.uuid)
  end

  private

  def destination_params
    params.require(:destination_form).permit(:name, :distance, :is_saved)
  end
end
