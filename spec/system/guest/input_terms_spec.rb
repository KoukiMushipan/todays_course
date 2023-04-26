require 'rails_helper'

RSpec.describe 'Guest::InputTerms' do
  before { visit new_guest_path }

  describe 'Page' do
    context 'ゲスト向け検索条件入力ページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_link '現在地取得'
        expect(page).to have_current_path new_guest_path
      end
    end
  end

  describe 'Contents' do
    context 'ゲスト向け検索条件入力ページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_button '検索'
        expect(find('form')['action']).to be_include guests_path
        expect(find('form')['method']).to eq 'get'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end
  end
end
