class DestinationsController < ApplicationController
  before_action :check_departure_session, only: %i[new create]
  before_action :check_results_session, only: %i[new create]
  before_action :check_result_session_for_destination_and_set_result, only: %i[new create]

  def new
    @destination_form = DestinationForm.new
    gon.locationInfo = {departure: session[:departure], destination: @result}
  end

  def create
    @destination_form = DestinationForm.new(destination_params)

    if !@destination_form.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      return render partial: 'create_failed', status: :unprocessable_entity
    end

    result_of_create_destination = CreateDestinationService.new(current_user, session[:departure], @destination_form, @result).call
    session[:destination] = result_of_create_destination[:destination]
    redirect_to new_history_path, flash: {success: result_of_create_destination[:success]}
  end

  private

  def destination_params
    params.require(:destination_form).permit(:name, :distance, :is_saved)
  end
end
