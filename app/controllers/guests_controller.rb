class GuestsController < ApplicationController
  layout 'guest', only: %i[index new create]

  skip_before_action :require_login
  skip_before_action :check_not_finished

  def index
    @guest_form = GuestForm.new(guest_form_params)

    departure_info = RequestGeocodeService.new(@guest_form).call
    if departure_info.include?(:error)
      flash.now[:error] = departure_info[:error]
      return render :new, status: :unprocessable_entity
    end

    @results = RequestNearbyService.new(departure_info, @guest_form).call
    if @results.include?(:error)
      flash.now[:error] = @results[:error]
      return render :new, status: :unprocessable_entity
    end

    gon.searchInfo = { results: @results, departure: departure_info, search_term: @guest_form.term }
  end

  def new
    @guest_form = GuestForm.new
  end

  private

  def guest_form_params
    params.require(:guest_form).permit(:address, :radius, :type)
  end
end
