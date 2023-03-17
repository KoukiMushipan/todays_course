RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :chrome
  end
end

# ログが出るが現状対処法は不明なため
Selenium::WebDriver.logger.ignore(%i[logger_info capabilities])
