require 'vcr'
require 'uri'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/support/cassettes'
  config.hook_into :webmock

  # VCRを使っていないときの通信を許可（開発時、必要に応じて一時的に許可する）
  # config.allow_http_connections_when_no_cassette = true

  # VCRを使用していなくてもローカルホストの通信は許可する
  config.ignore_localhost = true

  config.configure_rspec_metadata!

  # 新しいレコードの作成を許可（開発時、必要に応じて一時的にこちらに切り替える）
  # config.default_cassette_options = { record: :new_episodes, match_requests_on: %i[method path query uri] }

  # 新しいレコードの作成を許可しない（基本こちらにしておく）
  config.default_cassette_options = { match_requests_on: %i[method path query uri] }

  # APIキーを隠す
  config.filter_sensitive_data('<GoogleApiKey>') { Rails.application.credentials.google[:key] }

  # webdriverを使用するための通信は許可
  driver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }
  config.ignore_hosts(*driver_hosts)
end
