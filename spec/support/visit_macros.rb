module VisitMacros
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

  def visit_histories_page(history)
    login(history.user)
    sleep(0.2)
  end

  def visit_new_departure_page(user)
    login(user)
    sleep(0.1)
    visit new_departure_path
  end

  def visit_select_saved_departures_page(departure)
    visit_new_departure_page(departure.user)
    find('.fa.fa-folder-open.text-2xl').click
  end

  def visit_select_history_departure_page(departure)
    visit_new_departure_page(departure.user)
    find('.fa.fa-history.text-2xl').click
  end

  def visit_input_terms_page(departure)
    visit_new_departure_page(departure.user)
    find('.fa.fa-folder-open.text-2xl').click
    click_link '出発'
  end
end