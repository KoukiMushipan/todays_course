class ApplicationController < ActionController::Base
  # デバッグ用
  before_action :console_show

  private

  def console_show
    console
  end
end
