module SearchMacros
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
end
