class UserSessionsController < ApplicationController
  layout 'guest', only: %i[new]

  skip_before_action :require_login, only: %i[new create]
  skip_before_action :check_not_finished, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to profile_path, success: 'ログインしました'
    else
      redirect_to login_path, flash: { error: 'メールアドレス、もしくはパスワードが間違っています' }
    end
  end

  def destroy
    logout
    redirect_to login_path, status: :see_other, flash: { success: 'ログアウトしました' }
  end
end
