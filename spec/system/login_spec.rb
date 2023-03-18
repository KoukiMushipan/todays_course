require 'rails_helper'

RSpec.describe "Login", type: :system do
  let(:user) { create(:user) }
  describe 'ログイン' do
    before { visit login_path }

    context '正常な値を入力する' do
      it 'ログインが成功し、プロフィールページに遷移する' do
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'user-password'
        click_button 'ログイン'
        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq profile_path
      end
    end

    describe 'Authentications#email' do
      before { fill_in 'パスワード', with: 'user-password' }

      context 'メールアドレスを入力しない' do
        it 'ログインが失敗し、ページが遷移しない' do
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(current_path).to eq login_path
        end
      end

      context '間違ったメールアドレスを入力する' do
        it 'ログインが失敗し、ページが遷移しない' do
          fill_in 'メールアドレス', with: 'user-email-wrong@example.com'
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'Authentications#password' do
      before { fill_in 'メールアドレス', with: user.email }

      context 'パスワードを入力しない' do
        it 'ログインが失敗し、ページが遷移しない' do
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(current_path).to eq login_path
        end
      end

      context '間違ったパスワードを入力する' do
        it 'ログインが失敗し、ページが遷移しない' do
          fill_in 'パスワード', with: 'user-password-wrong'
          click_button 'ログイン'
          expect(page).to have_content 'メールアドレス、もしくはパスワードが間違っています'
          expect(current_path).to eq login_path
        end
      end
    end
  end
end
