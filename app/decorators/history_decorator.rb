class HistoryDecorator < ApplicationDecorator
  delegate_all

  def calc_time
    time = (end_time - start_time) / 60
    time.ceil.to_s
  end

  def from_what_time_to_what_time
    l(history.start_time, format: :short) + I18n.t('defaults.range_symbol') + l(history.end_time, format: :very_short)
  end

  def from_where_to_where
    departure.location.name + I18n.t('defaults.range_symbol') + destination.location.name
  end
end
