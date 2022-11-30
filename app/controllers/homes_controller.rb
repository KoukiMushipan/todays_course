class HomesController < ApplicationController
  layout 'top', only: %i[top]

  skip_before_action :require_login
  skip_before_action :check_not_finished

  def top; end
end
