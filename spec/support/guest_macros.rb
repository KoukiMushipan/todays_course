module GuestMacros
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
