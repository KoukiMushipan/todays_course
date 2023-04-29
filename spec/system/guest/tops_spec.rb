require 'rails_helper'

RSpec.describe 'Guest::Tops' do
  before { visit top_path }

  describe 'Page' do
    context 'トップページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_current_path top_path
      end

      it '共通レイアウトが正常に表示されている' do
        verify_guest_layout
      end
    end
  end

  describe 'Contents' do
    context 'トップページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_link 'ログインせずに目的地を探してみる', href: new_guest_path
        expect(page).to have_link 'まずは試してみる', href: new_guest_path
        expect(page).to have_link '新規登録してみる', href: signup_path
        expect(page).to have_link '利用規約', href: terms_path
        expect(page).to have_link 'プライバシーポリシー', href: 'https://kiyac.app/privacypolicy/MJIjHojL1fFp8ok7HOLL'
        expect(page).to have_link 'お問い合わせ', href: 'https://twitter.com/KoukiGyunyu'
      end
    end
  end
end
