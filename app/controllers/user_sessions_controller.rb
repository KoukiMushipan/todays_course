class UserSessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to :users
    else
      @error_message = 'メールアドレス、もしくはパスワードが間違っています'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to login_path, status: :see_other
  end
end
