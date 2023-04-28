module SavedPlaceMacros
  def visit_saved_departures_page(departure)
    login(departure.user)
    sleep(0.1)
    visit departures_path
    sleep(0.1)
    find('label[for=left]').click
  end

  def visit_edit_departure_page(departure)
    visit_saved_departures_page(departure)
    find('.fa.fa-chevron-down').click
    click_link('編集')
    sleep(0.1)
  end

  def visit_saved_destinations_page(destination)
    login(destination.user)
    sleep(0.1)
    visit departures_path
  end
end
