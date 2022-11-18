class ApplicationController < ActionController::Base
  def check_departure_session
    redirect_to new_search_departure_path, flash: {error: '出発地が設定されていません'} if !session[:departure]
  end

  def check_destination_session
    redirect_to new_destination_path, flash: {error: '目的地が設定されていません'} if !session[:destination]
  end

  def check_search_term_session
    redirect_to new_search_destination_path, flash: {error: "条件を入力してください"} if !session[:search_term]
  end

  def check_results_session
    redirect_to new_search_destination_path, flash: {error: '目的地の検索が実行されていません'} if !session[:results]
  end

  def check_course_params
    redirect_to new_history_path, flash: {error: '片道か往復から選択してください'} if !Settings.course_type.include?(params[:course])
  end

  def check_departure_session_and_set_departure_info
    check_departure_session
    @departure_info = session[:departure]
  end

  def check_destination_session_and_set_destination_info
    check_destination_session
    @destination_info = session[:destination]
  end

  def check_result_session_for_destination_and_set_result
    @result = session[:results].find {|result| result[:variable][:uuid] == params[:destination]}
    redirect_to search_destinations_path, flash: {error: '目的地を選択してください'} if !@result
  end
end
