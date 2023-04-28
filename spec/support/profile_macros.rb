module ProfileMacros
  def visit_histories_page(history)
    login(history.user)
    sleep(0.1)
  end

  def visit_setting_page(user)
    login(user)
    find('label[for=right]').click
  end
end
