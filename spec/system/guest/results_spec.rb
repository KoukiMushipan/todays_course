require 'rails_helper'

RSpec.describe 'Guest::Results' do
  let(:nearby_result) { Settings.nearby_result.radius_1000.to_hash }
  let(:guest_form) { build(:guest_form) }
  let(:guests_path_and_query) do
    query = { guest_form: { address: guest_form.address, radius: guest_form.radius, type: guest_form.type } }
    "#{guests_path}?#{query.to_query}&#{{ commit: '検索' }.to_query}"
  end

  before { visit_results_for_guest_page }

  describe 'Page' do
    context 'ゲスト向け検索結果ページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_current_path guests_path_and_query
      end

      it '共通レイアウトが正常に表示されている' do
        expect(page).to have_link "Today's Course", href: top_path
        expect(page).to have_link '新規登録', href: signup_path
        expect(page).to have_link 'ログイン', href: login_path
      end
    end
  end

  describe 'Contents' do
    context 'ゲスト向け検索結果ページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_content nearby_result[:variable][:name]
        expect(page).to have_content nearby_result[:fixed][:address]
      end

      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link '新規登録', href: signup_path
      end
    end
  end
end
