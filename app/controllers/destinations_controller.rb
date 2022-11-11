class DestinationsController < ApplicationController
  before_action :check_departure_session, only: %i[new create]
  before_action :check_results_session, only: %i[new create]
  before_action :check_result_for_destination, only: %i[new create]

  def new
    @destination = DestinationForm.new
    gon.locationInfo = {departure: session[:departure], destination: @result}
  end

  def create
    @destination = DestinationForm.new(destination_params)
    if !@destination.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    if @destination.is_saved
      destination = CreateDestinationService.new(current_user, session[:departure], @destination, @result).call
      @destination_info = destination.attributes_for_session
    else
      @destination_info = @destination.attributes_for_session(@result)
    end

    session[:destination] = @destination_info
    # redirect_to new_history_path(departure: @departure.uuid, destination: @destination.uuid)
  end

  private

  def check_departure_session
    redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !session[:departure]
  end

  def check_results_session
    redirect_to new_search_destination_path, flash: {error: "条件を入力してください"} if !session[:results]
  end

  def check_result_for_destination
    @result = session[:results].find {|result| result[:variable][:uuid] == params[:destination]}
    redirect_to search_destinations_path, flash: {error: "目的地を選択してください"} if !@result
  end

  def destination_params
    params.require(:destination_form).permit(:name, :distance, :is_saved)
  end
end
