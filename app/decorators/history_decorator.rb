class HistoryDecorator < ApplicationDecorator
  delegate_all

  def calc_time
    time = (end_time - start_time) / 60
    time.ceil.to_s
  end

end
