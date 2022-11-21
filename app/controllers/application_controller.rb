class ApplicationController < ActionController::Base
  helper_method %i(is_turbo_frame_request?)

  def is_turbo_frame_request? # viewでturbo_frameのリクエストであるか判別するためにhelper_method化
    return turbo_frame_request? # viewでは使えないメソッド
  end

  def required_none(url, flash_message)
    if turbo_frame_request?
      flash.now[flash_message.keys[0]] = flash_message.values[0]
      render partial: 'errors/required_none', status: :unprocessable_entity, locals: {url: url, flash_message: flash_message}
    else
      redirect_to url, flash: flash_message
    end
  end

  def check_departure_session
    if session[:departure].nil?
      url = new_search_departure_path
      flash_message = {error: '出発地が設定されていません'}
      required_none(url, flash_message)
    end
  end

  def check_destination_session
    if session[:destination].nil?
      url = new_destination_path
      flash_message = {error: '目的地が設定されていません'}
      required_none(url, flash_message)
    end
  end

  def check_search_term_session
    if session[:search_term].nil?
      url = new_search_destination_path
      flash_message = {error: '条件を入力してください'}
      required_none(url, flash_message)
    end
  end

  def check_results_session
    if session[:results].nil?
      url = new_search_destination_path
      flash_message = {error: '目的地の検索が実行されていません'}
      required_none(url, flash_message)
    end
  end

  def check_course_params
    if Settings.course_type.exclude?(params[:course])
      url = new_history_path
      flash_message = {error: '片道か往復から選択してください'}
      required_none(url, flash_message)
    end
  end

  def check_result_session_for_destination_and_set_result
    @result = session[:results].find {|result| result[:variable][:uuid] == params[:destination]}

    if @result.nil?
      url = search_destinations_path
      flash_message = {error: '目的地を選択してください'}
      required_none(url, flash_message)
    end
  end

  def check_departure_session_and_set_departure_info
    @departure_info = session[:departure]
    check_departure_session
  end

  def check_destination_session_and_set_destination_info
    @destination_info = session[:destination]
    check_destination_session
  end
end
