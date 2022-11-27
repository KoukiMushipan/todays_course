class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def show
    @one_week_moving_distance = History.one_week_moving_distance(current_user)
    @histories = current_user.histories.finished_list
    @total_moving_time = 0
    @histories.each {|history| @total_moving_time += ((history.end_time - history.start_time) / 60).to_i }
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to profile_path, flash: {success: 'ユーザー情報を更新しました'}
    else
      flash.now[:error] = 'ユーザー情報の更新に失敗しました'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    redirect_to login_path, status: :see_other, flash: {success: 'ユーザーを削除しました'}
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def set_user
    @user = User.find(current_user.id)
  end
end
