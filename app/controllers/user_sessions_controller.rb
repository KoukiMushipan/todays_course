class UserSessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to profile_path
    else
      flash.now[:alert] = 'メールアドレスかパスワードが間違っています'
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
    end
  end

  def destroy
    logout
    redirect_to login_path, status: :see_other
  end
end
