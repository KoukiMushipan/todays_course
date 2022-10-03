class UserSessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to profile_path, success: 'ログインしました'
    else
      flash.now[:error] = 'メールアドレスかパスワードが間違っています'
      render turbo_stream: turbo_stream.update('toast', partial: 'shared/toast')
    end
  end

  def destroy
    logout
    redirect_to login_path, status: :see_other, flash: {success: 'ログアウトしました'}
  end
end
