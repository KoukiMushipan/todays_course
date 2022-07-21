class UserSessionsController < ApplicationController
  skip_before_action :show_not_yet_goal
  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to search_departure_menu_path
    else
      flash.now[:alert] = t('process.failed_login')
      return render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
    end
  end

  def destroy
    logout
    redirect_to login_path, status: :see_other
  end
end
