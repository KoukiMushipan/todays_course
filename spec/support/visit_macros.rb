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
    sleep(0.1)
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

  def visit_search_results_page(departure)
    visit_input_terms_page(departure)
    fill_in '距離(1000m~5000m)', with: 5000
    click_button '検索'
  end

  def visit_new_destination_page(departure)
    visit_search_results_page(departure)
    click_link '決定'
  end

  def visit_new_destination_page_from_new_departure(user)
    visit_new_departure_page(user)
    geocode_mock(build(:location, :for_departure).attributes.compact.symbolize_keys)
    nearby_mock(Settings.nearby_result.radius_1000.to_hash)
    fill_in '名称', with: 'departure-name'
    fill_in '住所', with: 'departure-address'
    uncheck '保存する'
    click_button '決定'
    fill_in '距離(1000m~5000m)', with: 5000
    click_button '検索'
    click_link '決定'
  end

  def visit_start_page_from_new(departure)
    visit_new_destination_page(departure)
    fill_in '名称', with: 'destination-name'
    fill_in '片道の距離', with: 5000
    click_button '決定'
  end

  def visit_start_page_from_saved(destination)
    visit_saved_destinations_page(destination)
    click_link '出発'
  end

  def visit_start_page_from_not_saved(user)
    visit_new_destination_page_from_new_departure(user)
    fill_in '名称', with: 'destination-name'
    fill_in '片道の距離', with: 5000
    uncheck '保存する'
    click_button '決定'
  end

  def visit_goal_page_from_not_finished(history)
    login(history.user)
    sleep(0.1)
    click_link 'こちら'
  end

  def visit_show_history_page(history)
    login(history.user)
    sleep(0.1)
    visit history_path(history.uuid)
  end

  def visit_results_for_guest_page
    for_departure = build(:location, :for_departure)
    geocode_mock(for_departure.attributes.compact.symbolize_keys)
    nearby_mock(Settings.nearby_result.radius_1000.to_hash)
    visit new_guest_path
    fill_in '出発地の住所', with: for_departure.address
    fill_in '距離(1000m~5000m)', with: 5000
    select 'コンビニエンスストア', from: '目的地の種類'
    click_button '検索'
  end
end
