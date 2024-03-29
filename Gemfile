source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'rails', '~> 7.0.3', '>= 7.0.3.1'

gem 'sprockets-rails'

gem 'pg', '~> 1.1'

gem 'puma', '~> 5.0'

gem 'importmap-rails'

gem 'turbo-rails'

gem 'stimulus-rails'

gem 'tailwindcss-rails'

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'bootsnap', require: false

# 定数管理
gem 'config'

# decorator
gem 'draper'

# アイコン
gem 'font-awesome-rails'

# JSに変数を渡す
gem 'gon'

# メタタグ
gem 'meta-tags'

# 翻訳
gem 'rails-i18n'

# session
gem 'redis-actionpack'

# サイトマップ作成
gem 'sitemap_generator'

# ユーザー関連
gem 'sorcery'

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # データの作成
  gem 'factory_bot_rails'

  # ダミーデータ作成
  gem 'faker'

  # テスト
  gem 'rspec-rails'
end

group :development do
  gem 'web-console'

  # リントチェック
  gem 'rubocop', require: false

  # リントチェック拡張
  gem 'rubocop-rails', require: false

  # rspecリントチェック
  gem 'rubocop-rspec', require: false
end

group :test do
  # テスト用フレームワーク
  gem 'capybara'

  # ウェブドライバーの自動インストールとアップデート、Seleniumテストをより簡単に実行
  gem 'webdrivers'

  # テストの際のAPI通信を最初の一回のみ行い、使い回す
  gem 'vcr'

  # APIへのコールをモック
  gem 'webmock'
end
