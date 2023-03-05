module ApplicationHelper
  def flash?
    flash[:success] || flash[:error]
  end
end
