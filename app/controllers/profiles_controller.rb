class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'ユーザー情報を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    redirect_to login_path, status: :see_other, notice: 'ユーザーを削除しました'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def set_user
    @user = User.find(current_user.id)
  end
end
