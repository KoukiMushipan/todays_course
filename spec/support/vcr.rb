require 'vcr'


VCR.configure do |config|
  config.cassette_library_dir = 'spec/support/cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
  config.configure_rspec_metadata!

  # 新しいレコードの作成を許可（開発時、必要に応じて一時的にこちらに切り替える）
  # config.default_cassette_options = { record: :new_episodes, match_requests_on: %i[method path query uri] }

  # 新しいレコードの作成を許可しない（基本こちらにしておく）
  config.default_cassette_options = { match_requests_on: %i[method path query uri] }

  config.filter_sensitive_data('<GoogleApiKey>') { Rails.application.credentials.google[:key] }
end
