class UsersController < ApplicationController
  layout 'gest', only: %i[new create]

  skip_before_action :require_login, only: %i[new create]
  skip_before_action :check_not_finished, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to profile_path, flash: {success: '新規作成に成功しました'}
    else
      flash.now[:error] = '新規作成に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
