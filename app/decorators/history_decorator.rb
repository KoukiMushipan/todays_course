class HistoryDecorator < ApplicationDecorator
  delegate_all

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

  def departure_uuid
    destination.departure.uuid
  end

  def departure_name
    destination.departure.location.name
  end

  def departure_address
    destination.departure.location.address
  end

  def destination_uuid
    destination.uuid
  end

  def destination_name
    destination.location.name
  end

  def destination_address
    destination.location.address
  end
end
