class GuestsController < ApplicationController
  layout 'guest', only: %i[index new create]

  skip_before_action :require_login
  skip_before_action :check_not_finished

  def index
    @guest_form = GuestForm.new(guest_form_params)
    return render_new_guest('入力情報に誤りがあります') unless @guest_form.valid?

    departure_info = Api::GeocodeService.new(@guest_form).call
    return render_new_guest('位置情報の取得に失敗しました') unless departure_info

    @results = Api::NearbyService.new(departure_info, @guest_form).call
    return render_new_guest('目的地が見つかりませんでした') unless @results

    gon.searchInfo = { results: @results, departure_info:, search_term: @guest_form.term }
  end

  def new
    @guest_form = GuestForm.new
  end

  private

  def render_new_guest(error_message)
    flash.now[:error] = error_message
    render :new, status: :unprocessable_entity
  end

  def guest_form_params
    params.require(:guest_form).permit(:address, :radius, :type)
  end
end
