module LayoutMacros
  def verify_guest_layout
    expect(page).to have_link "Today's Course", href: top_path
    expect(page).to have_link '新規登録', href: signup_path
    expect(page).to have_link 'ログイン', href: login_path
  end

  def verify_user_layout
  end
end
