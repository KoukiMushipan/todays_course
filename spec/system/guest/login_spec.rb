require 'rails_helper'

RSpec.describe 'Guest::Login' do
  let(:user) { create(:user) }

  before { visit login_path }

  describe 'Page' do
    context 'ログインページにアクセスする' do
      it '情報が正しく表示されている' do
        expect(page).to have_current_path login_path
        expect(page).to have_content 'ログイン'
        expect(page).to have_field 'メールアドレス', with: ''
        expect(page).to have_field 'パスワード', with: ''
      end
    end
  end

  describe 'Contents' do
    context 'ログインページにアクセスする' do
      it 'リンク関連が正しく表示されている' do
        expect(page).to have_button 'ログイン'
        expect(find('form')['action']).to be_include login_path
        expect(find('form')['method']).to eq 'post'
        expect(page).not_to have_field('_method', type: 'hidden')
      end
    end
  end

  describe 'Validations' do
    context '正常な値を入力する' do
      it 'ログインが成功し、プロフィールページに遷移する' do
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'user-password'
        click_button 'ログイン'
        expect(page).to have_content 'ログインしました'
        expect(page).to have_current_path profile_path
      end
    end
  end

  describe 'Authentications' do
    describe '#email' do
      before { fill_in 'パスワード', with: 'user-password' }

      context 'メールアドレスを入力しない' do
        it 'ログインが失敗し、ページが遷移しない' do
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(page).to have_current_path login_path
        end
      end

      context '間違ったメールアドレスを入力する' do
        it 'ログインが失敗し、ページが遷移しない' do
          fill_in 'メールアドレス', with: 'user-email-wrong@example.com'
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(page).to have_current_path login_path
        end
      end
    end

    describe '#password' do
      before { fill_in 'メールアドレス', with: user.email }

      context 'パスワードを入力しない' do
        it 'ログインが失敗し、ページが遷移しない' do
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(page).to have_current_path login_path
        end
      end

      context '間違ったパスワードを入力する' do
        it 'ログインが失敗し、ページが遷移しない' do
          fill_in 'パスワード', with: 'user-password-wrong'
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(page).to have_current_path login_path
        end
      end
    end
  end

  describe 'Form' do
    context 'メールアドレスを入力し、ログインに失敗する' do
      it 'フォームから入力したメールアドレスが消えていない' do
        email = 'user-email@example.com'
        fill_in 'メールアドレス', with: email
        click_button 'ログイン'
        expect(page).to have_field 'メールアドレス', with: email
      end
    end

    context 'パスワードを入力し、新規作成に失敗する' do
      it '入力したパスワードがフォームから消えている' do
        fill_in 'パスワード', with: 'user-password'
        click_button 'ログイン'
        expect(page).to have_field 'パスワード', with: ''
      end
    end
  end
end
