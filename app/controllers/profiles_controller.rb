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
      flash.now[:success] = 'ユーザー情報を更新しました'
      render turbo_stream: turbo_stream.replace('profile', partial: 'profile')
    else
      flash.now[:error] = '入力情報に誤りがあります'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    redirect_to signup_path, status: :see_other, flash: {success: 'ユーザーを削除しました'}
  end

  def cancel; end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def set_user
    @user = User.find(current_user.id)
  end
end
