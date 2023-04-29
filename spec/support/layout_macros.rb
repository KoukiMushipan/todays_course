module LayoutMacros
  def verify_guest_layout
    expect(page).to have_link "Today's Course", href: top_path
    expect(page).to have_link '新規登録', href: signup_path
    expect(page).to have_link 'ログイン', href: login_path
  end

  def verify_user_layout
    nav_search_icon = find('.fa.fa-search.nav-icon').find(:xpath, '..')
    expect(URI.parse(nav_search_icon[:href]).path).to eq new_departure_path

    nav_folder_icon = find('.fa.fa-folder-open.nav-icon').find(:xpath, '..')
    expect(URI.parse(nav_folder_icon[:href]).path).to eq departures_path

    nav_user_icon = find('.fa.fa-user.nav-icon').find(:xpath, '..')
    expect(URI.parse(nav_user_icon[:href]).path).to eq profile_path
  end
end
