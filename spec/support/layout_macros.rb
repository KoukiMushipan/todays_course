module LayoutMacros
  def nav_search_icon
    a_tag = find('.fa.fa-search.nav-icon').find(:xpath, '..')
    URI.parse(a_tag[:href]).path
  end

  def nav_folder_icon
    a_tag = find('.fa.fa-folder-open.nav-icon').find(:xpath, '..')
    URI.parse(a_tag[:href]).path
  end

  def nav_user_icon
    a_tag = find('.fa.fa-user.nav-icon').find(:xpath, '..')
    URI.parse(a_tag[:href]).path
  end
end
