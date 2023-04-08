class HistoryDecorator < ApplicationDecorator
  delegate_all
  delegate :uuid, to: :destination, prefix: :destination

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def moving_time
    ((end_time - start_time) / 60).floor
  end
end
