class GestsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :check_not_finished

  def index
  end

  def new
  end

  def create
  end
end
