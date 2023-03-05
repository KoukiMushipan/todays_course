class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :check_not_finished

  helper_method %i[is_turbo_frame_request?]

  def not_authenticated
    redirect_to login_path, flash: { error: 'ログインしてください' }
  end

  def check_departure_session
    return if session[:departure].present?

    url = new_departure_path
    flash_message = { error: '出発地が設定されていません' }
    required_none(url, flash_message)
  end

  def check_destination_session
    return if session[:destination].present?

    url = new_destination_path
    flash_message = { error: '目的地が設定されていません' }
    required_none(url, flash_message)
  end

  def check_search_term_session
    return if session[:search_term].present?

    url = new_search_path
    flash_message = { error: '条件を入力してください' }
    required_none(url, flash_message)
  end

  def check_candidates_session
    return if session[:results].present?

    url = new_search_path
    flash_message = { error: '目的地の検索が実行されていません' }
    required_none(url, flash_message)
  end

  def check_course_params
    return if Settings.course_type.include?(params[:course])

    url = new_history_path
    flash_message = { error: '片道か往復から選択してください' }
    required_none(url, flash_message)
  end

  def check_not_finished
    @not_finished_history = current_user.histories.not_finished&.first
    flash.now[:notice] = 'まだゴールしていません' if @not_finished_history
  end

  def check_and_set_candidate_from_session
    @candidate = find_candidate
    return if @candidate.present?

    url = searches_path
    flash_message = { error: '目的地を選択してください' }
    required_none(url, flash_message)
  end

  def check_and_set_departure_info_from_session
    @departure_info = session[:departure]
    check_departure_session
  end

  def check_and_set_destination_info_from_session
    @destination_info = session[:destination]
    check_destination_session
  end

  private

  # viewでturbo_frameのリクエストであるか判別するためにhelper_method化
  def is_turbo_frame_request?
    turbo_frame_request? # viewでは使用できないメソッド
  end

  def required_none(url, flash_message)
    if turbo_frame_request?
      flash.now[flash_message.keys[0]] = flash_message.values[0]
      render partial: 'errors/required_none', status: :unprocessable_entity, locals: { url:, flash_message: }
    else
      redirect_to url, flash: flash_message
    end
  end

  def find_candidate
    candidate = session[:results].find do |result|
      result[:variable][:uuid] == params[:destination]
    end

    candidate ||= session[:nearby_commented_info].find do |destination|
      destination[:variable][:uuid] == params[:destination]
    end

    candidate
  end
end
