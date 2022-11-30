class GestsController < ApplicationController
  layout 'gest', only: %i[index new create]

  skip_before_action :require_login
  skip_before_action :check_not_finished

  def index
    @gest_form = GestForm.new(gest_form_params)
    departure_info = RequestGeocodeService.new(@gest_form).call

    if departure_info.include?(:error)
      flash.now[:error] = departure_info[:error]
      return render :new, status: :unprocessable_entity
    end

    @results = RequestNearbyService.new(departure_info, @gest_form).call
    if @results.include?(:error)
      flash.now[:error] = @results[:error]
      return render :new, status: :unprocessable_entity
    end

    gon.searchInfo = {results: @results, departure: departure_info, search_term: @gest_form.term}
  end

  def new
    @gest_form = GestForm.new
  end

  private

  def gest_form_params
    params.require(:gest_form).permit(:address, :radius, :type)
  end
end
