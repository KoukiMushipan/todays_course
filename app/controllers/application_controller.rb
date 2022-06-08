class ApplicationController < ActionController::Base
  before_action :console_show

  private

  def console_show
    console
  end
end
